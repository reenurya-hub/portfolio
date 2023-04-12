create or replace PACKAGE BODY PAC_POS_CARGUE AS
/**************************************************************************
    NOMBRE:         PAC_POS_CARGUE
    TIPO:        5.0   PAQUETE
    PROPOSITO:      Contiene la funcionalidad relacionada con el cargue
					masivo del producto BCH
    CREADO POR:     Company - PYA

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         22/02/2020  Company - LMCT         Documentacion del paquete
    2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB (INCLUSION,EXCLUSION,AJUSTE TOMADOR ASEGURADO , FECHA, GENERO)
    3.0         06/06/2020  Company                CAMBIO DE ESTRUCTURA, PRORRATA DE LOS RECIBOS, DOS MOVIMIENTOS EN LA EXCLUSION, TIPO Y NUMERO IDENTIFICACION
    4.0         07/07/2020  Company                Actualizacion maestro del cargue masivo de asegurados
    5.0         08/07/2020  Company - DML          Se ajusta para que no cree recibos en caratula para polizas - Recibo por: asegurado
    6.0         09/07/2020  Company                Se actualiza estado del cargue por defecto a IN																	  
    7.0         10/07/2020  Company - DML          Se valida que si existen certificados en curso no deja subir propuesta																	  
    8.0         15/07/2020  Company - PY           Retorno Recobro, fecha vencimiento en los recibos
    9.0         07/08/2020  Company                Se garantiza valor en el campo total regitros del cargue masivo
   10.0         04/08/2020  Company                AR 36669 - Inconsistencias al validar cargue masivo
   11.0         10/08/2020  Company                AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
   12.0         18/08/2020  Company                Ajustes columna ESTADO_PROCESO
   13.0         27/08/2020  Company                AR 37035 - Incidencias HU-EMI-APGP-017
   14.0         29/08/2020  Company - JR           Ajuste performance
   15.0         29/08/2020  Company                AR 37070 - Incidencias HU-EMI-PW-APGP-012
   16.0         08/09/2020  Company                AR 37175 - Incidencias HU-EMI-PW-APGP-012
   17.0         11/09/2020  Company                AR 37166 - Incidencias HU-EMI-APGP-004 
   18.0         15/09/2020  Company - JR           Ajuste terminacion proceso cargue masivo
   19.0         21/09/2020  Company                AR 37224 - Incidencias HU-EMI-PW-APGP-014
   20.0         28/09/2020  Company                AR 37416 - Incidencias Validacion Cargue Masivo
   21.0         15/10/2020  Company                LR 37224 - Incidencias HU-EMI-PW-APGP-014
   22.0         27/10/2020  Company                AR 37681 - Incidencia prorateo recibo extorno cargue masivo
   23.0         12/11/2020  Company                Ar 37845 Incidencias Preproduccion Revision Movimientos PW vs iAXIS
   24.0         28/11/2020  Company                Factura Electronica
   25.0         07/01/2021  Company                Ar 37659
   26.0         20/01/2021  Company                Ar 38616
   27.0         02/02/2021  Company                ID CP 205 Cargue Masivo 27-01-2021
   28.0         23/01/2021  Company                ROADMAP VIDA II DESEMPLEO Se ajudta funcion de Convenios, se adiciona campo nmonto null
   29.0         24/03/2021  Company                Ar 37175
   30.0         26/03/2021  Company                Ar 39558 Validacion de fecha de exclusion anterior a fecha efecto inclusion asegurado
   31.0         06/04/2021  Company                Control de cambios cargue masivo validacion direccion, departamento y ciudad
   32.0         07/04/2021  Company                Ar 39653 - Validacion tipo documento numero unico identificacion
   33.0         07/04/2021  Company                Ar 38673 - Inconsistencia valor recibos prima trimestral
   33.0         08/04/2021  Company                Ar 38674 - Inconsistencia valor recibos boton nuevo
   34.0         08/04/2021  Company                Ar 39679 - Inconsistencia fecha efecto recibo caratula
   35.0         14/04/2021  Company                Ar 37659
   36.0         16/04/2021  Company                Ar 39694 - Inconsistencia validacion datos Direccion, ciudad y departamento
   37.0         16/04/2021  Company                Ar 37659
   38.0         19/04/2021  Company                Ar 39788 - Incidencias envio recibos a SAP
   39.0         20/04/2021  Company                Ar 37659
   40.0         20/04/2021  Company                Ar 39815

***************************************************************************/

  ----------------------------------------------------------------------------
  --  SECCION CONSTANTES
  ----------------------------------------------------------------------------
  c_char_underline              CONSTANT VARCHAR2(1) DEFAULT '_';
  c_n                           CONSTANT VARCHAR2(1) DEFAULT 'N';
  c_s                           CONSTANT VARCHAR2(1) DEFAULT 'S';
  c_cod_estructura              CONSTANT VARCHAR2(12) DEFAULT 'ESTRUCTURA';
  --Codigo para indicar que el tipo de validacion a realizar es de un grupo valores
  c_tipo_val_grupo              CONSTANT VARCHAR2(12) DEFAULT 'GRUPO';
  c_tipo_val_fecha_mayor_act    CONSTANT VARCHAR2(19) DEFAULT 'FECHA_MAYOR_ACTUAL';
  c_formato_dd_mm_yyyy          CONSTANT VARCHAR2(12) DEFAULT 'DD/MM/RRRR';
  --Codigo Aseguradora
  c_cod_aseg_origen             CONSTANT msv_tb_parametro.codigo%TYPE DEFAULT 'COD_ASEG_ORIGEN';
  --Codigos de los errores del cargue
  c_cod_error_no_num            CONSTANT VARCHAR2(7) DEFAULT 'ECG0001';
  c_cod_error_formato_fecha     CONSTANT VARCHAR2(7) DEFAULT 'ECG0002';
  c_cod_error_fecha_no_val      CONSTANT VARCHAR2(7) DEFAULT 'ECG0003';
  c_cod_error_tdato_no_conocido CONSTANT VARCHAR2(7) DEFAULT 'ECG0004';
  c_cod_error_campo_ne_tabla    CONSTANT VARCHAR2(7) DEFAULT 'ECG0005';
  c_cod_error_no_permite_null   CONSTANT VARCHAR2(7) DEFAULT 'ECG0006';
  c_cod_error_longitud          CONSTANT VARCHAR2(7) DEFAULT 'ECG0007';
  c_cod_error_no_tiene_benef    CONSTANT VARCHAR2(7) DEFAULT 'ECG0008';
  c_cod_error_porcentaje_100    CONSTANT VARCHAR2(7) DEFAULT 'ECG0009';
  c_cod_error_no_estructura     CONSTANT VARCHAR2(7) DEFAULT 'ECG0010';
  c_cod_error_no_ciudad         CONSTANT VARCHAR2(7) DEFAULT 'ECG0011';
  c_cod_error_valor_no_valido   CONSTANT VARCHAR2(7) DEFAULT 'ECG0012';
  c_cod_error_vlr_no_param      CONSTANT VARCHAR2(7) DEFAULT 'ECG0013';
  c_cod_error_general_no_cargo  CONSTANT VARCHAR2(7) DEFAULT 'ECG0014';
  c_cod_error_inesperado        CONSTANT VARCHAR2(7) DEFAULT 'ECG0015';
  c_cod_error_inconsistencias   CONSTANT VARCHAR2(7) DEFAULT 'ECG0016';
  c_cod_error_aseguradora       CONSTANT VARCHAR2(7) DEFAULT 'ECG0017';
  c_cod_error_cant_registros    CONSTANT VARCHAR2(7) DEFAULT 'ECG0018';
  c_cod_error_tipo_cancel       CONSTANT VARCHAR2(7) DEFAULT 'ECG0019';
  c_cod_error_tipo_producto     CONSTANT VARCHAR2(7) DEFAULT 'ECG0020';
  c_cod_error_modalidad         CONSTANT VARCHAR2(7) DEFAULT 'ECG0021';  -- 51746 14/08/2019
  --
  c_grupo_error_gasera          CONSTANT VARCHAR2(30) DEFAULT 'GR_COD_ERROR_GASERA';
  c_grupo_genero                CONSTANT VARCHAR2(11) DEFAULT 'GR_GENERO';
  c_grupo_cargue_masivo         CONSTANT VARCHAR2(19) DEFAULT 'GR_CARGUE_MASIVO';

  --Nombres de las tablas destino del cargue
  c_nombre_tabla_exequial       CONSTANT VARCHAR2(30) DEFAULT 'GSE_TB_EXEQUIAL_DETALLE';
  c_nombre_tabla_doblecupon     CONSTANT VARCHAR2(30) DEFAULT 'GSE_TB_DOBLECUPON_DETALLE';
  c_nombre_tabla_vida           CONSTANT VARCHAR2(30) DEFAULT 'GSE_TB_VIDA_DETALLE';
  c_nombre_tabla_vida_benef     CONSTANT VARCHAR2(30) DEFAULT 'GSE_TB_VIDA_BENEFICIARIOS';
  c_nombre_tabla_ventas_diarias CONSTANT VARCHAR2(30) DEFAULT 'BCH_TB_VENTASDIARIAS_DETALLE';
  c_nombre_tabla_facturacion    CONSTANT VARCHAR2(30) DEFAULT 'BCH_TB_FACTURACION_DETALLE';
  c_nombre_tabla_novedades      CONSTANT VARCHAR2(30) DEFAULT 'BCH_TB_NOVEDADES_DETALLE';
  c_nombre_tabla_renovaciones   CONSTANT VARCHAR2(30) DEFAULT 'BCH_TB_RENOVACIONES_DETALLE';
  c_nombre_tabla_cancelaciones  CONSTANT VARCHAR2(30) DEFAULT 'BCH_TB_CANCELACIONES_DETALLE';

  --Id de las columnas de la tabla <<GSE_TB_EXEQUIAL_DETALLE>>
  c_id_col_tipo_doc_exequial     CONSTANT NUMBER DEFAULT 4;

  --Id de las columnas de la tabla <<GSE_TB_VIDA_DETALLE>>
  c_id_col_tipo_doc_vida        CONSTANT NUMBER DEFAULT 4;

  --Id de las columnas de la tabla <<GSE_TB_VIDA_BENEFICIARIOS>>
  c_id_col_tipo_doc_vida_dep    CONSTANT NUMBER DEFAULT 4;

  ----------------------------------------------------------------------------
  --  SECCION TYPE
  ----------------------------------------------------------------------------
  n_sproduc                     msv_tb_cargue_masivo.sproduc%TYPE;

  -- INICIO - 16/04/2021 Ar 37659
  ----------------------------------------------------------------------------
  --  SECCION VARIABLES GLOBALES
  ----------------------------------------------------------------------------
  v_nmovimi_in                  movseguro.nmovimi%TYPE;
  v_nmovimi_ex                  movseguro.nmovimi%TYPE;
  -- FIN - 16/04/2021 Ar 37659
  -- INICIO - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP
  v_idcargue                    NUMBER;
  v_sproces                     NUMBER;
  -- FIN - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP
  ----------------------------------------------------------------------------
  --  SECCION CURSORES GLOBALES PRIVADOS
  ----------------------------------------------------------------------------
  CURSOR cu_info_cargue(p_cargue_id      msv_tb_cargue_masivo.id%TYPE)
  IS
    SELECT
        id_cargue
        ,nro_linea
        ,texto
        ,observaciones
        ,estado
        ,usuario_creacion
        ,fecha_creacion
        ,usuario_modificacion
        ,fecha_modificacion
      FROM msv_tb_cargue_masivo_det
     WHERE id_cargue = p_cargue_id
     ORDER BY nro_linea ASC;

  ----------------------------------------------------------------------------
  --  SECCION DEFINICION DE TYPE PERSONALIZADOS
  ----------------------------------------------------------------------------
  -- Se define un type tipo tabla para contener los registros a procesar del cargue
  TYPE TYP_T_CARGUE_MASIVO IS TABLE OF cu_info_cargue%ROWTYPE INDEX BY BINARY_INTEGER;

  -- Se define un type tipo record para contener el nombre de la tabla,
  -- el nombre de la columna, el tipo de dato
  TYPE typ_rec_tabla IS RECORD(
    nombre_tabla        VARCHAR2(31)
    ,tipo_dato          user_tab_columns.data_type%TYPE
    ,permite_nulo       user_tab_columns.nullable%TYPE
    ,longitud           user_tab_columns.data_length%TYPE
    ,columna_id         user_tab_columns.column_id%TYPE
    ,nombre_columna     user_tab_columns.column_name%TYPE
  );

  -- Se define un type tipo tabla indexado con un varchar2, que sera
  -- la clave, compuesto por el nombre de la tabla y el id de la columna
  -- Ej: <<NOMBRE_TABLA_COLUMNA_ID>>
  TYPE typ_tabla IS TABLE OF typ_rec_tabla INDEX BY VARCHAR2(62);
  t_typ_tabla     typ_tabla;

  -- Se define un type tipo record para contener el nombre del grupo
  TYPE typ_rec_parametro IS RECORD(
    nombre_grupo        VARCHAR2(40)
    ,tipo_validacion    VARCHAR2(22)
  );

  -- Se define un type tipo tabla indexado con un VARCHAR2, que sera
  -- la clave, compuesto por el nombre de la tabla y el id de la columna
  --Esto para contener los campos a validar de las tablas segun el grupo de
  --parametros
  TYPE typ_parametro IS TABLE OF typ_rec_parametro INDEX BY VARCHAR2(62);
  t_typ_par     typ_parametro;
  --Type con la lista de columnas de tablas a validar la fecha de nacimiento
  t_typ_fecha     typ_parametro;

  ----------------------------------------------------------------------------
  --  SECCION PROCEDIMIENTOS/FUNCIONES PRIVADAS
  ----------------------------------------------------------------------------
 FUNCTION fu_agrega_info_type(
    p_nombre_tabla_in    IN  user_tab_columns.table_name%TYPE
   ,p_columna_id_in      IN  user_tab_columns.column_id%TYPE
   ,p_tipo_dato_in       IN  user_tab_columns.data_type%TYPE
   ,p_longitud_in        IN  user_tab_columns.data_length%TYPE
   ,p_nulo_in            IN  user_tab_columns.nullable%TYPE
   ,p_nombre_columna_in  IN  user_tab_columns.column_name%TYPE
   ,p_clave_type_in      IN  VARCHAR2)
RETURN typ_tabla
IS
/**************************************************************************
    NOMBRE:         fu_agrega_info_type
    TIPO:           Funcion
    PROPOSITO:      Funcion encargada de agregar al type global, la informacion
                    de la columna de la tabla consultada
    CREADO POR:     Company


    PARAMETROS DE ENTRADA:
    Nombre                      Tipo            Descripcion
    -------------------         --------        -----------------------
    p_nombre_tabla_in           VARCHAR2        Nombre de la tabla destino
    p_nombre_campo_in           VARCHAR2        Nombre del campo de la tabla destino
    p_tipo_dato_in              VARCHAR2        Tipo de dato del campo
    p_longitud_in               VARCHAR2        Longitud del valor permitido en el campo
    p_nulo_in                   VARCHAR2        Indicador, S: permite null o N: no nullo

    PARAMETROS DE SALIDA:
    Nombre                      Tipo        Descripcion
    ---------                   --------    -----------------------------------
    p_codigo_error_out          VARCHAR2    Codigo del error encontrado, en caso
                                            de no cumplir el tipo de dato
    RETURN                      VARCHAR2    Devuelve type tipo table => typ_rec_tabla

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         01/12/2017  Company                Creacion y documentacion de funcion

***************************************************************************/
  -----------------------------------------------------------------------------
  -- SECCION VARCHAR
  -----------------------------------------------------------------------------
  --Contendra la clave en el type tipo table
  v_clave                VARCHAR2(70);

BEGIN
  t_typ_tabla(p_clave_type_in).nombre_tabla := p_nombre_tabla_in;
  t_typ_tabla(p_clave_type_in).tipo_dato    := p_tipo_dato_in;
  t_typ_tabla(p_clave_type_in).permite_nulo := p_nulo_in;
  t_typ_tabla(p_clave_type_in).longitud     := p_longitud_in;
  t_typ_tabla(p_clave_type_in).columna_id   := p_columna_id_in;
  t_typ_tabla(p_clave_type_in).nombre_columna := p_nombre_columna_in;

  RETURN t_typ_tabla;

END fu_agrega_info_type;

PROCEDURE pr_inicia_type_parametro
IS
/**************************************************************************
    NOMBRE:         pr_inicia_type_parametro
    TIPO:           Procedimiento
    PROPOSITO:      Procedimiento encargada de inicializar y cargar los id de las columnas,
                    cuyos valores permitidos solo son los de un grupo de parametros
    CREADO POR:     Company


    PARAMETROS DE ENTRADA:
    Nombre                      Tipo            Descripcion
    -------------------         --------        -----------------------

    PARAMETROS DE SALIDA:
    Nombre                      Tipo        Descripcion
    ---------                   --------    -----------------------------------
    RETURN                      VARCHAR2    Devuelve type tipo table => typ_rec_parametro

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         11/12/2017  Company                Creacion y documentacion de funcion

***************************************************************************/
  -----------------------------------------------------------------------------
  -- SECCION VARCHAR
  -----------------------------------------------------------------------------
  --Contendra la clave en el type tipo table
  v_clave                VARCHAR2(70);
  v_inicia_clave         VARCHAR2(70);

  --Id de las columnas de la tabla <<GSE_TB_VIDA_DETALLE>>
  c_id_col_fecha_nacimiento     CONSTANT NUMBER DEFAULT 9;
  c_id_col_genero_vida          CONSTANT NUMBER DEFAULT 10;
  c_id_col_fecha_soli_vida      CONSTANT NUMBER DEFAULT 12;

  c_id_col_plan_mod_a_vida      CONSTANT NUMBER DEFAULT 14;
  c_id_col_plan_mod_b_vida      CONSTANT NUMBER DEFAULT 15;
  c_id_col_plan_mod_c_vida      CONSTANT NUMBER DEFAULT 16;
  c_id_col_modalidad_vida       CONSTANT NUMBER DEFAULT 17;
  c_id_col_plan_mod_b_adi_vida  CONSTANT NUMBER DEFAULT 23;

  --Id de las columnas de la tabla <<GSE_TB_VIDA_BENEFICIARIOS>>
  c_id_col_fecha_nacimiento_ben CONSTANT NUMBER DEFAULT 9;
  c_id_col_genero_vida_dep      CONSTANT NUMBER DEFAULT 10;
  c_id_col_exequial_vida_dep    CONSTANT NUMBER DEFAULT 15;
  c_id_col_parentesco_vida_dep  CONSTANT NUMBER DEFAULT 17;

  --Id de las columnas de la tabla <<GSE_TB_EXEQUIAL_DETALLE>>
  c_id_col_fecha_nacimiento_exe  CONSTANT NUMBER DEFAULT 9;
  c_id_col_genero_exequial       CONSTANT NUMBER DEFAULT 10;
  c_id_col_fecha_soli_exequial   CONSTANT NUMBER DEFAULT 14;
  c_id_col_operador_exequial     CONSTANT NUMBER DEFAULT 20;
  c_id_col_dpto_smart_exequial   CONSTANT NUMBER DEFAULT 21;
  c_id_col_local_smart_exequial  CONSTANT NUMBER DEFAULT 22;

  --Id de las columnas de la tabla <<GSE_TB_DOBLECUPON_DETALLE>>
  c_id_col_fecha_soli_doble      CONSTANT NUMBER DEFAULT 7;

BEGIN
  --Si no se ha cargado previamente
  IF t_typ_par.COUNT = 0 THEN
  --
    --Columnas de la tabla <<GSE_TB_VIDA_DETALLE>>
    v_inicia_clave := c_nombre_tabla_vida||c_char_underline;

    v_clave  := v_inicia_clave||c_id_col_tipo_doc_vida;
    t_typ_par(v_clave).nombre_grupo := 'GR_HO_DOC_GASE_IAXIS';

    v_clave  := v_inicia_clave||c_id_col_genero_vida;
    t_typ_par(v_clave).nombre_grupo := 'GR_GENERO';

    v_clave  := v_inicia_clave||c_id_col_plan_mod_a_vida;
    t_typ_par(v_clave).nombre_grupo := 'GR_PLAN_MOD_A_TMP';

    v_clave  := v_inicia_clave||c_id_col_plan_mod_b_vida;
    t_typ_par(v_clave).nombre_grupo := 'GR_PLAN_MOD_B_TMP';

    v_clave  := v_inicia_clave||c_id_col_plan_mod_c_vida;
    t_typ_par(v_clave).nombre_grupo := 'GR_PLAN_MOD_C_TMP';
    t_typ_par(v_clave).tipo_validacion := c_tipo_val_grupo;

    v_clave  := v_inicia_clave||c_id_col_modalidad_vida;
    t_typ_par(v_clave).nombre_grupo    := 'GR_MODALIDAD_TMP';

    v_clave  := v_inicia_clave||c_id_col_plan_mod_b_adi_vida;
    t_typ_par(v_clave).nombre_grupo := 'GR_PLAN_MODB_ADI_TMP';

    --Se carga el type con los id de columnas de fechas a validar que no superen la fecha actual
    IF t_typ_fecha.COUNT =  0 THEN
    --
      v_clave  := v_inicia_clave||c_id_col_fecha_nacimiento;
      t_typ_par(v_clave).tipo_validacion := c_tipo_val_fecha_mayor_act;

      v_clave  := v_inicia_clave||c_id_col_fecha_soli_vida;
      t_typ_par(v_clave).tipo_validacion := c_tipo_val_fecha_mayor_act;
    --
    END IF;

    --Columnas de la tabla <<GSE_TB_VIDA_BENEFICIARIOS>>
    v_inicia_clave := c_nombre_tabla_vida_benef||c_char_underline;

    v_clave  := v_inicia_clave||c_id_col_tipo_doc_vida_dep;
    t_typ_par(v_clave).nombre_grupo := 'GR_HO_DOC_GASE_IAXIS';

    v_clave  := v_inicia_clave||c_id_col_genero_vida_dep;
    t_typ_par(v_clave).nombre_grupo := 'GR_GENERO';

    v_clave  := v_inicia_clave||c_id_col_parentesco_vida_dep;
    t_typ_par(v_clave).nombre_grupo := 'GR_PARENTESCO_TMP';

    v_clave  := v_inicia_clave||c_id_col_exequial_vida_dep;
    t_typ_par(v_clave).nombre_grupo := 'GR_EXEQUIAL_TMP';

    --Se carga el type con los id de columna de fecha de nacimiento para el beneficiario
    v_clave  := v_inicia_clave||c_id_col_fecha_nacimiento_ben;
    t_typ_par(v_clave).tipo_validacion := c_tipo_val_fecha_mayor_act;

    --Columnas de la tabla <<GSE_TB_EXEQUIAL_DETALLE>>
    v_inicia_clave := c_nombre_tabla_exequial||c_char_underline;

    v_clave  := v_inicia_clave||c_id_col_tipo_doc_exequial;
    t_typ_par(v_clave).nombre_grupo := 'GR_HO_DOC_GASE_IAXIS';

    v_clave  := v_inicia_clave||c_id_col_genero_exequial;
    t_typ_par(v_clave).nombre_grupo := 'GR_GENERO';

    v_clave  := v_inicia_clave||c_id_col_operador_exequial;
    t_typ_par(v_clave).nombre_grupo := 'GR_OPERADOR_GASERA';

    v_clave  := v_inicia_clave||c_id_col_dpto_smart_exequial;
    t_typ_par(v_clave).nombre_grupo := 'GR_DPTO_SMART_TMP';

    v_clave  := v_inicia_clave||c_id_col_local_smart_exequial;
    t_typ_par(v_clave).nombre_grupo := 'GR_LOCAL_SMART_TMP';

    --Se carga el type con los id de columna de fecha de nacimiento para exequial
    v_clave  := v_inicia_clave||c_id_col_fecha_nacimiento_exe;
    t_typ_par(v_clave).tipo_validacion := c_tipo_val_fecha_mayor_act;

    v_clave  := v_inicia_clave||c_id_col_fecha_soli_exequial;
    t_typ_par(v_clave).tipo_validacion := c_tipo_val_fecha_mayor_act;

    --Columnas de la tabla <<GSE_TB_DOBLECUPON_DETALLE>>
    v_inicia_clave := c_nombre_tabla_doblecupon||c_char_underline;

    --Se carga el type con los id de columna de fecha solicitud de doble cupon
    v_clave  := v_inicia_clave||c_id_col_fecha_soli_doble;
    t_typ_par(v_clave).tipo_validacion := c_tipo_val_fecha_mayor_act;
  --
  END IF;


 EXCEPTION
   WHEN OTHERS THEN
     p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_INICIA_TYPE_PARAMETRO',1,'EXCEPCION GENERAL: ' || Sqlerrm || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
END pr_inicia_type_parametro;

FUNCTION fu_get_type_info_tabla(
  p_nombre_tabla_in    IN  user_tab_columns.table_name%TYPE
 ,p_columna_id_in      IN  user_tab_columns.column_id%TYPE
 ,p_clave_type_in      IN  VARCHAR2
 ,p_codigo_error_out         OUT  VARCHAR2
 ,p_indicador_proceso_out    OUT  VARCHAR2
)
RETURN typ_tabla
IS
/**************************************************************************
    NOMBRE:         fu_get_type_info_tabla
    TIPO:           Funcion
    PROPOSITO:      Funcion encargada de actualizar el type que contiene
                    la informacion de la tabla recibida, el tipo de dato
                    si permite null, la longitud que permite el campo
    CREADO POR:     Company


    PARAMETROS DE ENTRADA:
    Nombre                      Tipo            Descripcion
    -------------------         --------        -----------------------
    p_nombre_tabla_in           VARCHAR2        Nombre de la tabla destino
    p_nombre_campo_in           VARCHAR2        Nombre del campo de la tabla destino
    p_valor_campo_in            VARCHAR2        Valor a validar del campo

    PARAMETROS DE SALIDA:
    Nombre                      Tipo        Descripcion
    ---------                   --------    -----------------------------------
    p_codigo_error_out          VARCHAR2    Codigo del error encontrado, en caso
                                            de no cumplir el tipo de dato
    RETURN                      VARCHAR2    Devuelve type tipo table => typ_rec_tabla

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         01/12/2017  Company                Creacion y documentacion de funcion

***************************************************************************/
  ----------------------------------------------------------------------------
  --  SECCION CONSTANTES
  ----------------------------------------------------------------------------
  c_nombre_procedimiento      VARCHAR2(30) DEFAULT 'fu_get_type_info_tabla';
  -----------------------------------------------------------------------------
  -- SECCION VARCHAR
  -----------------------------------------------------------------------------
  v_tipo_dato                user_tab_columns.data_type%TYPE;
  v_nulo                     user_tab_columns.nullable%TYPE;
  v_nombre_columna           user_tab_columns.column_name%TYPE;

  -----------------------------------------------------------------------------
  -- SECCION NUMBER
  -----------------------------------------------------------------------------
  n_longitud_dato            user_tab_columns.data_length%TYPE;

  -----------------------------------------------------------------------------
  -- SECCION CURSORES
  -----------------------------------------------------------------------------
  --Consulta el tipo, longitud, y si permite null
  CURSOR cu_campo(p_nombre_tabla   user_tab_columns.table_name%TYPE
                  ,p_columna_id   user_tab_columns.column_id%TYPE)
  IS
  SELECT data_type
         ,COALESCE(data_precision,data_length)
         ,DECODE(nullable,'Y',c_s,c_n) as nullable
         ,column_name
    FROM user_tab_columns
   WHERE table_name = p_nombre_tabla
     AND column_id = p_columna_id;

  -----------------------------------------------------------------------------
  -- SECCION %TYPE
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION BOOLEAN
  -----------------------------------------------------------------------------
  b_existe_dato              BOOLEAN DEFAULT FALSE;

  -----------------------------------------------------------------------------
  -- SECCION EXCEPTION
  -----------------------------------------------------------------------------
  e_no_existe_campo          EXCEPTION;
  -----------------------------------------------------------------------------
  -- SECCION DATE
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION PROCEDIMIENTOS/FUNCIONES PRIVADAS
  -----------------------------------------------------------------------------
BEGIN
   b_existe_dato := FALSE;

   --Valida si ya se ha consultado antes el campo de la tabla, para evitar consultar
   --de nuevo
   IF (NOT(t_typ_tabla.EXISTS(p_clave_type_in))) THEN
   --
      OPEN cu_campo(p_nombre_tabla_in, p_columna_id_in);
      FETCH cu_campo INTO v_tipo_dato, n_longitud_dato, v_nulo, v_nombre_columna;
        IF (cu_campo%FOUND) THEN
          b_existe_dato := TRUE;

          --Se agrega la informacion encontrada al type global con la informacion de la columna de la tabla
          t_typ_tabla := fu_agrega_info_type(p_nombre_tabla_in
                                            ,p_columna_id_in
                                            ,v_tipo_dato
                                            ,n_longitud_dato
                                            ,v_nulo
                                            ,v_nombre_columna
                                            ,p_clave_type_in);
        END IF;
      CLOSE cu_campo;
   --
   ELSE
   --
      b_existe_dato := TRUE;
   --
   END IF;

   --Si el dato no existe se devuelve error
   IF NOT(b_existe_dato) THEN
     RAISE e_no_existe_campo;
   END IF;

   p_indicador_proceso_out := pac_msv_constantes.c_respuesta_exitosa;

  RETURN t_typ_tabla;

  EXCEPTION
  WHEN OTHERS THEN
     p_indicador_proceso_out := pac_msv_constantes.c_fallo_error_datos;
     p_codigo_error_out := REPLACE(c_cod_error_campo_ne_tabla,'{0}',p_columna_id_in);
END fu_get_type_info_tabla;

FUNCTION fu_correcto_null(
  p_nombre_tabla_in    IN  user_tab_columns.table_name%TYPE
 ,p_columna_id_in      IN  user_tab_columns.column_id%TYPE
 ,p_valor_campo_in     IN  VARCHAR2
 ,p_clave_type_in      IN  VARCHAR2
 ,p_codigo_error_out   OUT  VARCHAR2
)
RETURN VARCHAR2
IS
/**************************************************************************
    NOMBRE:         fu_correcto_null
    TIPO:           Funcion
    PROPOSITO:      Funcion encargada de validar en la tabla destino el
                    campo, si permite o no null, esto valida segun el valor recibido, en caso de
                    no cumplir se devuelve N: No es correcto, S: Es correcto
    CREADO POR:     Company


    PARAMETROS DE ENTRADA:
    Nombre                      Tipo            Descripcion
    -------------------         --------        -----------------------
    p_nombre_tabla_in           VARCHAR2        Nombre de la tabla destino
    p_columna_id_in             VARCHAR2        Columna id del campo a validar
    p_valor_campo_in            VARCHAR2        Valor a validar del campo

    PARAMETROS DE SALIDA:
    Nombre                      Tipo        Descripcion
    ---------                   --------    -----------------------------------
    p_codigo_error_out          VARCHAR2    Codigo del error encontrado, en caso
                                            de no cumplir
    RETURN                      VARCHAR2    Devuelve N:no cumple, S:Cumple

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         01/12/2017  Company                Creacion y documentacion de funcion

***************************************************************************/
  -----------------------------------------------------------------------------
  -- SECCION VARCHAR
  -----------------------------------------------------------------------------
  v_permite_nulo            VARCHAR2(1);
  -----------------------------------------------------------------------------
  -- SECCION NUMBER
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION CURSORES
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION %TYPE
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION BOOLEAN
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION EXCEPTION
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION DATE
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION PROCEDIMIENTOS/FUNCIONES PRIVADAS
  -----------------------------------------------------------------------------
BEGIN
   --Se agrega la informacion encontrada al type global con la informacion de la columna de la tabla
   t_typ_tabla := fu_get_type_info_tabla(p_nombre_tabla_in
                                          ,p_columna_id_in
                                          ,p_clave_type_in
                                          ,p_codigo_error_out
                                          ,v_indicador_proceso);

  --Si el dato no existe se devuelve error
  IF v_indicador_proceso <> pac_msv_constantes.c_respuesta_exitosa THEN
     RETURN c_n;
  END IF;

  --Se obtiene si la columna permite null
  v_permite_nulo := t_typ_tabla(p_clave_type_in).permite_nulo;
  p_codigo_error_out := c_cod_error_no_permite_null;
  IF (p_valor_campo_in IS NULL OR LENGTHC(TRIM(p_valor_campo_in)) IS NULL) AND v_permite_nulo = c_n THEN
     RETURN c_n;
  ELSE
     RETURN c_s;
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
     RETURN c_n;
END fu_correcto_null;

FUNCTION fu_cumple_longitud(
  p_nombre_tabla_in    IN  user_tab_columns.table_name%TYPE
 ,p_columna_id_in      IN  user_tab_columns.column_id%TYPE
 ,p_valor_campo_in     IN  VARCHAR2
 ,p_clave_type_in      IN  VARCHAR2
 ,p_codigo_error_out   OUT  VARCHAR2
)
RETURN VARCHAR2
IS
/**************************************************************************
    NOMBRE:         fu_cumple_longitud
    TIPO:           Funcion
    PROPOSITO:      Funcion encargada de validar en la tabla destino el
                    campo, si permite o no null, esto valida segun el valor recibido, en caso de
                    no cumplir se devuelve N: No es correcto, S: Es correcto
    CREADO POR:     Company


    PARAMETROS DE ENTRADA:
    Nombre                      Tipo            Descripcion
    -------------------         --------        -----------------------
    p_nombre_tabla_in           VARCHAR2        Nombre de la tabla destino
    p_columna_id_in             VARCHAR2        Columna id del campo a validar
    p_valor_campo_in            VARCHAR2        Valor a validar del campo

    PARAMETROS DE SALIDA:
    Nombre                      Tipo        Descripcion
    ---------                   --------    -----------------------------------
    p_codigo_error_out          VARCHAR2    Codigo del error encontrado, en caso
                                            de no cumplir
    RETURN                      VARCHAR2    Devuelve N:no cumple, S:Cumple

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         01/12/2017  Company                Creacion y documentacion de funcion

***************************************************************************/

  -----------------------------------------------------------------------------
  -- SECCION VARCHAR
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION NUMBER
  -----------------------------------------------------------------------------
  n_longitud_dato            user_tab_columns.data_length%TYPE;

  -----------------------------------------------------------------------------
  -- SECCION CURSORES
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION %TYPE
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION BOOLEAN
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION EXCEPTION
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION DATE
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION PROCEDIMIENTOS/FUNCIONES PRIVADAS
  -----------------------------------------------------------------------------
BEGIN
   --Se agrega la informacion encontrada al type global con la informacion de la columna de la tabla
   t_typ_tabla := fu_get_type_info_tabla(p_nombre_tabla_in
                                          ,p_columna_id_in
                                          ,p_clave_type_in
                                          ,p_codigo_error_out
                                          ,v_indicador_proceso);

   --Si el dato no existe se devuelve error
   IF v_indicador_proceso <> pac_msv_constantes.c_respuesta_exitosa THEN
     RETURN c_n;
   END IF;

  --Se obtiene si la columna permite null
  n_longitud_dato := t_typ_tabla(p_clave_type_in).longitud;
  p_codigo_error_out := c_cod_error_longitud;

  IF (LENGTHB(p_valor_campo_in) > n_longitud_dato) AND (t_typ_tabla(p_clave_type_in).tipo_dato <> 'DATE') THEN
    RETURN c_n;
  ELSE
    RETURN c_s;
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
     RETURN c_n;
END fu_cumple_longitud;

FUNCTION fu_correcto_tipo_dato(
  p_nombre_tabla_in    IN  user_tab_columns.table_name%TYPE
 ,p_columna_id_in      IN  user_tab_columns.column_id%TYPE
 ,p_valor_campo_in     IN  VARCHAR2
 ,p_clave_type_in      IN  VARCHAR2
 ,p_codigo_error_out   OUT  VARCHAR2
)
RETURN VARCHAR2
IS
/**************************************************************************
    NOMBRE:         fu_correcto_tipo_dato
    TIPO:           Funcion
    PROPOSITO:      Funcion encargada de validar en la tabla destino el
                    tipo de dato del campo, segun el valor recibido, en caso de
                    no cumplir se devuelve N: No es correcto, S: Es correcto
    CREADO POR:     Company


    PARAMETROS DE ENTRADA:
    Nombre                      Tipo            Descripcion
    -------------------         --------        -----------------------
    p_nombre_tabla_in           VARCHAR2        Nombre de la tabla destino
    p_nombre_campo_in           VARCHAR2        Nombre del campo de la tabla destino
    p_valor_campo_in            VARCHAR2        Valor a validar del campo

    PARAMETROS DE SALIDA:
    Nombre                      Tipo        Descripcion
    ---------                   --------    -----------------------------------
    p_codigo_error_out          VARCHAR2    Codigo del error encontrado, en caso
                                            de no cumplir el tipo de dato
    RETURN                      VARCHAR2    Devuelve N:

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         01/12/2017  Company                Creacion y documentacion de funcion

***************************************************************************/
  -----------------------------------------------------------------------------
  -- SECCION VARCHAR
  -----------------------------------------------------------------------------
  v_tipo_dato                user_tab_columns.data_type%TYPE;

  -----------------------------------------------------------------------------
  -- SECCION NUMBER
  -----------------------------------------------------------------------------
  n_aux_num                  NUMBER;

  -----------------------------------------------------------------------------
  -- SECCION CURSORES
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION %TYPE
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION BOOLEAN
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION EXCEPTION
  -----------------------------------------------------------------------------
  e_tipo_no_valido           EXCEPTION;
  -----------------------------------------------------------------------------
  -- SECCION DATE
  -----------------------------------------------------------------------------
  d_aux_fec                  DATE;

  -----------------------------------------------------------------------------
  -- SECCION PROCEDIMIENTOS/FUNCIONES PRIVADAS
  -----------------------------------------------------------------------------
BEGIN
  --Valida que el valor no sea vacio
  IF p_valor_campo_in IS NOT NULL THEN

     --Se agrega la informacion encontrada al type global con la informacion de la columna de la tabla
     t_typ_tabla := fu_get_type_info_tabla(p_nombre_tabla_in
                                            ,p_columna_id_in
                                            ,p_clave_type_in
                                            ,p_codigo_error_out
                                            ,v_indicador_proceso);

     --Si el dato no existe se devuelve error
     IF v_indicador_proceso <> pac_msv_constantes.c_respuesta_exitosa THEN
       RETURN c_n;
     END IF;

     --Se obtiene el tipo de dato de la columna
     v_tipo_dato     := t_typ_tabla(p_clave_type_in).tipo_dato;

     --Validacion del tipo de dato segun el campo
     IF v_tipo_dato IN ('NUMBER', 'FLOAT')   THEN
       <<tipo_number>>
       BEGIN
          SELECT TO_NUMBER(p_valor_campo_in) INTO n_aux_num FROM dual;

          IF n_aux_num IS NULL THEN
            p_codigo_error_out := c_cod_error_no_num;
            RAISE e_tipo_no_valido;
          END IF;
      EXCEPTION
      WHEN OTHERS THEN
        p_codigo_error_out := c_cod_error_no_num;
        RAISE e_tipo_no_valido;
      END tipo_number;
     ELSIF v_tipo_dato IN
            ('CHAR', 'VARCHAR', 'VARCHAR2', 'NVARCHAR2', 'NCHAR VARYING') THEN
            RETURN c_s;
     ELSIF v_tipo_dato IN ('DATE') THEN
        <<val_fecha>>
        BEGIN
          SELECT TO_DATE(p_valor_campo_in, c_formato_dd_mm_yyyy)
            INTO d_aux_fec
            FROM dual;

          IF d_aux_fec IS NULL THEN
            p_codigo_error_out := c_cod_error_fecha_no_val;
            RAISE e_tipo_no_valido;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            p_codigo_error_out := c_cod_error_fecha_no_val;
            RAISE e_tipo_no_valido;
        END val_fecha;
     END IF;
  END IF;

  RETURN c_s;

  EXCEPTION
  WHEN e_tipo_no_valido THEN
    RETURN c_n;
  WHEN OTHERS THEN
    p_codigo_error_out := c_cod_error_tdato_no_conocido;
     RETURN c_n;
END fu_correcto_tipo_dato;

FUNCTION fu_adiciona_error(
    p_cod_error_in    IN   VARCHAR2
    ,p_observacion_in IN   VARCHAR2
    ,p_nombre_columna_in  IN  user_tab_columns.column_name%TYPE
)
RETURN VARCHAR2
IS
/**************************************************************************
    NOMBRE:         fu_adiciona_error
    TIPO:           Funcion
    PROPOSITO:      Funcion encargada de buscar la descripcion del codigo de error
                    recibido, y adicionar dicho error a la observacion, con el
                    respectivo campo al que pertenece
    CREADO POR:     Company


    PARAMETROS DE ENTRADA:
    Nombre                      Tipo            Descripcion
    -------------------         --------        -----------------------
    p_cod_error_in              VARCHAR2        Codigo del error recibido
    p_observacion_in            VARCHAR2        Cadena con la observacion
    p_nombre_columna_in         VARCHAR2        Nombre de la columna donde se presenta
                                                el error

    PARAMETROS DE SALIDA:
    Nombre                      Tipo        Descripcion
    ---------                   --------    -----------------------------------
    RETURN                      VARCHAR2    Devuelve la cadena de la observacion

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         01/12/2017  Company                Creacion y documentacion de funcion

***************************************************************************/
  -----------------------------------------------------------------------------
  -- SECCION VARCHAR
  -----------------------------------------------------------------------------
  v_parametro                msv_tb_parametro.valor%TYPE;
  v_msg_final                msv_tb_cargue_masivo_det.observaciones%TYPE;

BEGIN
    --Obtener el mensaje del codigo de error recibido
    v_parametro := pac_msv_utilidades.fu_valor_parametro(
                    p_cod_error_in
                    ,c_grupo_error_gasera);

    --Si ya existe un error registrado, se agrega a la observacion
    IF (LENGTH(p_observacion_in) != 0) THEN
      v_msg_final := p_observacion_in||';';
    END IF;

    --Si supera la cantidad de caracteres el nuevo mensaje de error
    IF (LENGTH(p_observacion_in) + LENGTH(v_parametro) >= 3000) THEN
      v_msg_final := p_observacion_in || '...';
    ELSE
      v_msg_final := v_msg_final ||'<'||p_nombre_columna_in||':'||v_parametro|| '>';
    END IF;

    RETURN  v_msg_final;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN p_observacion_in;
END fu_adiciona_error;

FUNCTION fu_homologa_tipo_doc(
  p_codigo_tipo_doc_in     IN  VARCHAR2
)
RETURN VARCHAR2
IS
/**************************************************************************
    NOMBRE:         fu_homologa_tipo_doc
    TIPO:           Funcion
    PROPOSITO:      Encargado  de homologar el tipo de documento con iaxis
    CREADO POR:     Company


    PARAMETROS DE ENTRADA:
    Nombre                      Tipo            Descripcion
    -------------------         --------        -----------------------
    p_codigo_tipo_doc_in        VARCHAR2        Tipo Identificador del documento
                                                que se recibe en el archivo plano

    PARAMETROS DE SALIDA:
    Nombre                      Tipo        Descripcion
    ---------                   --------    -----------------------------------
    Identificador               VARCHAR2    Codigo de Iaxis que identifica el tipo
                                            de documento recibido

    EXCEPCIONES
    Nombre          Descripcion
    ---------       -------------------------------------------------------

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         07/12/2017  Company - LMCT         Creacion y documentacion de funcion

***************************************************************************/
----------------------------------------------------------------------------
--  SECCION CONSTANTES
----------------------------------------------------------------------------
c_nombre_procedimiento      VARCHAR2(20) DEFAULT 'fu_homologa_tipo_doc';

----------------------------------------------------------------------------
--  SECCION VARCHAR
----------------------------------------------------------------------------
v_codigo         msv_tb_parametro.valor%TYPE;
v_codigo_tmp     msv_tb_parametro.valor%TYPE;

----------------------------------------------------------------------------
--  SECCION NUMBER
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--  SECCION CURSORES
----------------------------------------------------------------------------
CURSOR cu_tipo_doc_iaxis(p_codigo  VARCHAR2)
IS
  SELECT D.CATRIBU-- INTO v_codigo
  FROM DETVALORES D, DETVALORES_DEP DD
  WHERE D.CVALOR = DD.CVALORDEP AND D.CATRIBU = DD.CATRIBUDEP
  AND DD.CEMPRES    = 12
  AND DD.CVALOR     = 85
  AND DD.CVALORDEP  = 672
  AND D.CIDIOMA     = 8
  AND D.CATRIBU     <> 0
  and DD.CATRIBUDEP = p_codigo
  ORDER BY D.CATRIBU;

----------------------------------------------------------------------------
--  SECCION TYPE PERSONALIZADOS
----------------------------------------------------------------------------


BEGIN
    --Se consulta el parametro del tipo de documento a homologar
    v_codigo_tmp := pac_msv_utilidades.fu_valor_parametro
      (
        p_codigo_tipo_doc_in
        ,'GR_HO_DOC_GASE_IAXIS'
      );

    --Valida que sean datos numericos, sino devuelve vacio
    IF (NOT(pac_msv_utilidades.fu_es_numero(v_codigo_tmp)))
    THEN
      v_codigo_tmp := '';
    END IF;

    v_codigo := v_codigo_tmp;

    OPEN    cu_tipo_doc_iaxis(v_codigo_tmp);
    FETCH   cu_tipo_doc_iaxis INTO v_codigo;
      IF (cu_tipo_doc_iaxis%FOUND) THEN
        --Valida que sean datos numericos, sino devuelve vacio
        IF (NOT(pac_msv_utilidades.fu_es_numero(v_codigo))) THEN
          v_codigo := '';
        END IF;
      ELSE
         v_codigo := '';
      END IF;
    CLOSE   cu_tipo_doc_iaxis;

    RETURN v_codigo;

 --
 EXCEPTION
 WHEN OTHERS THEN
    pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
        p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
        ,p_ntraza_in          => 929
        ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        ,p_usuario_in         => USER
        ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
    );
    RETURN '';
 --
END fu_homologa_tipo_doc;

FUNCTION fu_existe_parametro_grupo(
    p_grupo_in       IN  msv_tb_parametro.grupo%TYPE
   ,p_codigo_in      IN  msv_tb_parametro.codigo%TYPE)
RETURN VARCHAR2
IS
/**************************************************************************
    NOMBRE:         fu_existe_parametro_grupo
    TIPO:           Funcion
    PROPOSITO:      Funcion encargada de validar si el parametro existe en el grupo
    CREADO POR:     Company


    PARAMETROS DE ENTRADA:
    Nombre                      Tipo            Descripcion
    -------------------         --------        -----------------------
    p_grupo_in                  VARCHAR2        Nombre del grupo
    p_codigo_in                 VARCHAR2        Nombre del codigo

    PARAMETROS DE SALIDA:
    Nombre                      Tipo        Descripcion
    ---------                   --------    -----------------------------------
    RETURN                      VARCHAR2    Devuelve S:Si existe, N:No existe

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         11/12/2017  Company                Creacion y documentacion de funcion

***************************************************************************/
----------------------------------------------------------------------------
--  SECCION CONSTANTES
----------------------------------------------------------------------------
c_nombre_procedimiento      VARCHAR2(30) DEFAULT 'fu_existe_parametro_grupo';

----------------------------------------------------------------------------
--  SECCION VARCHAR
----------------------------------------------------------------------------
--Para contener el mensaje de error
v_msg_error_parametro    msv_tb_parametro.valor%TYPE;
--Contiene el valor consultado del parametro
v_parametro              msv_tb_parametro.valor%TYPE;

----------------------------------------------------------------------------
--  SECCION NUMBER
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--  SECCION CURSORES
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--  SECCION TYPE PERSONALIZADOS
----------------------------------------------------------------------------


BEGIN

  -----------------------------------------------------------------------
  --1. Se obtiene el codigo del parametro
  -----------------------------------------------------------------------
  v_msg_error_parametro := pac_msv_utilidades.c_msg_parametro_no_valido;
  v_msg_error_parametro := REPLACE(v_msg_error_parametro, pac_msv_utilidades.c_codigo_parametro, p_codigo_in);
  v_msg_error_parametro := REPLACE(v_msg_error_parametro, pac_msv_utilidades.c_nombre_grupo, p_grupo_in);

  --Se consulta el parametro
  v_parametro := pac_msv_utilidades.fu_valor_parametro(p_codigo_in, p_grupo_in);

  --Se valida si devuelve error
  IF (v_msg_error_parametro = v_parametro) THEN
    RETURN c_n;
  ELSE
    RETURN c_s;
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    RETURN c_n;
END fu_existe_parametro_grupo;

PROCEDURE pr_valida_cargue_x_tipo(
  p_info_cargue_in            IN   pac_msv_utilidades.t_array
  ,p_usuario_in               IN   msv_tb_cargue_masivo.usuario_creacion%TYPE
  ,p_nombre_tabla_in          IN   VARCHAR2
  ,p_cod_id_columnas_in       IN   VARCHAR2
  ,p_indicador_proceso_out    OUT  VARCHAR2
  ,p_observacion_proceso_out  OUT  VARCHAR2)
IS
/**************************************************************************
    NOMBRE:         pr_valida_cargue_x_tipo
    TIPO:           Procedimiento
    PROPOSITO:      Procedimiento encargado de validar el registro del cargue
    CREADO POR:     Company


    PARAMETROS DE ENTRADA:
    Nombre                      Tipo            Descripcion
    -------------------         --------        -----------------------
    p_tipo_cargue_in            NUMBER          Tipo de cargue, Ventas Diarias, Facturacion, otros
    p_info_cargue_in            TABLE OF
                                VARCHAR2(32767) Arreglo con la informacion de cada registro

    PARAMETROS DE SALIDA:
    Nombre                      Tipo        Descripcion
    ---------                   --------    -----------------------------------
    p_indicador_proceso_out     VARCHAR     Indicador resultado del proceso
    p_observacion_proceso_out   VARCHAR     Texto con el restultado del proceso

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         13/03/2018  Company                 Creacion y documentacion de funcion

***************************************************************************/
  ----------------------------------------------------------------------------
  --  SECCION CONSTANTES
  ----------------------------------------------------------------------------
  c_nombre_procedimiento        CONSTANT VARCHAR2(30) DEFAULT 'pr_valida_cargue_x_tipo';

  --Validacion Ventas diarias
  c_info_col_tipdoc_ventas      CONSTANT NUMBER DEFAULT 2;
  c_info_col_numtel_ventas      CONSTANT NUMBER DEFAULT 5;
  c_info_col_codciudad_ventas   CONSTANT NUMBER DEFAULT 6;
  c_info_col_dep_ventas         CONSTANT NUMBER DEFAULT 7;
  c_info_col_depinm_ventas      CONSTANT NUMBER DEFAULT 14;
  c_info_col_valoraseg_ventas   CONSTANT NUMBER DEFAULT 16;
  c_info_col_numcre_ventas      CONSTANT NUMBER DEFAULT 17;

  --Validacion Facturacion
  c_info_col_tippol_facturacion     CONSTANT NUMBER DEFAULT 2;
  c_info_col_tipdoc_facturacion     CONSTANT NUMBER DEFAULT 3;
  c_info_col_numpol_facturacion     CONSTANT NUMBER DEFAULT 8;
  c_info_col_valoraseg_facturac     CONSTANT NUMBER DEFAULT 9;
  c_info_col_depinm_facturacion     CONSTANT NUMBER DEFAULT 13;
  c_info_col_codciudad_facturac     CONSTANT NUMBER DEFAULT 16;

  -- Validacion Novedades
  c_info_col_tipo_novedad           CONSTANT NUMBER DEFAULT 1;
  --Columnas que no se validan Ventas diarias
  c_col_excl_ventas                 CONSTANT NUMBER DEFAULT 3;

  --Columnas que no se validan facturacion
  c_col_excl_facturacion            CONSTANT NUMBER DEFAULT 5;

  -----------------------------------------------------------------------------
  -- SECCION VARCHAR
  -----------------------------------------------------------------------------
  v_observa_error            VARCHAR2(4000);
  v_codigo_error             VARCHAR2(100);
  v_parametro                msv_tb_parametro.valor%TYPE;
  --Contendra la clave en el type tipo table
  v_clave                    VARCHAR2(70);
  v_max_estrato              msv_tb_parametro.valor%TYPE;
  v_tipo_documento_iaxis     VARCHAR2(10);
  v_correcto_tipo_dato       VARCHAR2(1) DEFAULT c_n;

  -----------------------------------------------------------------------------
  -- SECCION NUMBER
  -----------------------------------------------------------------------------
  i_idx_info PLS_INTEGER;
  n_col_excluidas NUMBER;
  -----------------------------------------------------------------------------
  -- SECCION CURSORES
  -----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION %TYPE
  ----------------------------------------------------------------------------
  --Contendra en un array los id de las columnas donde se cargaran los datos
  --del cargue
  t_cols_id         pac_msv_utilidades.t_array;

  ----------------------------------------------------------------------------
  -- SECCION BOOLEAN
  ----------------------------------------------------------------------------
  b_tiene_error              BOOLEAN DEFAULT FALSE;
  b_validar_tipo_dato        BOOLEAN DEFAULT FALSE;

  ----------------------------------------------------------------------------
  -- SECCION %ROWTYPE
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION EXCEPCIONES
  ----------------------------------------------------------------------------

BEGIN


  --Se arma type con clave <<NOMBRE_TABLA_COLUMNA_ID>>, que va contener las columnas a validar por tabla
  --el cual se usara para validar si el dato existe parametrizado segun el grupo dentro del type
  pr_inicia_type_parametro();

  v_parametro := pac_msv_utilidades.fu_valor_parametro(
                  p_cod_id_columnas_in
                  ,c_grupo_cargue_masivo);



  --Se obtienen los id de las columnas separados
  t_cols_id := pac_msv_utilidades.fu_split(v_parametro, pac_msv_constantes.c_caracter_coma);
  v_observa_error := '';



  --Se evalua el tipo de cargue x validar
  CASE p_nombre_tabla_in
    ---------------------------------------------------
    --   CARGUE VENTAS DIARIAS
    ---------------------------------------------------
    WHEN c_nombre_tabla_ventas_diarias THEN
    n_col_excluidas := c_col_excl_ventas;
    i_idx_info := 0;
    ---------------------------------------------------
    --   CARGUE FACTURACION
    ---------------------------------------------------
    WHEN c_nombre_tabla_facturacion THEN
    n_col_excluidas := c_col_excl_facturacion;
    i_idx_info := 1;
    ---------------------------------------------------
    --   CARGUE NOVEDADES
    ---------------------------------------------------
    WHEN c_nombre_tabla_novedades THEN
    i_idx_info := 1;
    ---------------------------------------------------
    --   CARGUE CANCELACIONES
    ---------------------------------------------------
    WHEN c_nombre_tabla_cancelaciones THEN
    i_idx_info := 1;
   ---------------------------------------------------
    --   CARGUE RENOVACIONES
    ---------------------------------------------------
    WHEN c_nombre_tabla_renovaciones THEN
    i_idx_info := 1;
  END CASE;

  --Se verifica que la estructura del archivo corresponda con la esperada
  IF (t_cols_id.COUNT != p_info_cargue_in.COUNT - n_col_excluidas) THEN
  --


    b_tiene_error := TRUE;
  --
  ELSE
      --
      <<leer_cols>>
      BEGIN
          --Se recorre la lista de id de columnas a validar
          FOR idx IN t_cols_id.first .. t_cols_id.last
          LOOP

          --

              --Se arma una clave con el nombre de la tabla y el id de la columna
              v_clave := p_nombre_tabla_in||c_char_underline||t_cols_id(idx);
              b_validar_tipo_dato := TRUE;


        --Se aumenta el contador para validar el id con la info correcta
           IF  p_nombre_tabla_in = c_nombre_tabla_ventas_diarias THEN
            --
              IF i_idx_info = c_info_col_dep_ventas
                 OR i_idx_info = c_info_col_depinm_ventas THEN
                --
                i_idx_info := i_idx_info + 1;
                --
              END IF;
           ELSIF p_nombre_tabla_in = c_nombre_tabla_facturacion THEN
            --
             IF i_idx_info = c_info_col_tippol_facturacion  or i_idx_info = c_info_col_codciudad_facturac THEN
                i_idx_info := i_idx_info + 1;
              ELSIF i_idx_info = c_info_col_depinm_facturacion THEN
                    i_idx_info := i_idx_info + 2;
              END IF;
            --
           /*ELSIF p_nombre_tabla_in = c_nombre_tabla_novedades THEN
            IF i_idx_info = c_info_col_tipo_novedad THEN
              i_idx_info := i_idx_info + 2;
            END IF;
          /* ELSIF p_nombre_tabla_in = c_nombre_tabla_cancelaciones THEN
            IF i_idx_info = c_info_col_tipo_novedad THEN
              i_idx_info := i_idx_info + 2;
            END IF;*/
           END IF;
           --
              <<valida_null>>
              BEGIN
                --Se valida si la columna permite o no null, con respecto al valor recibido
                IF  fu_correcto_null(
                        p_nombre_tabla_in
                       ,t_cols_id(idx)           --Identificador de la columna
                       ,p_info_cargue_in(i_idx_info)    --Valor del campo en el cargue
                       ,v_clave
                       ,v_codigo_error) = c_n THEN
                  --Se agrega el error a la observacion
                  v_observa_error := fu_adiciona_error(v_codigo_error, v_observa_error, t_typ_tabla(v_clave).nombre_columna);
                  b_tiene_error := TRUE;
                END IF;
              EXCEPTION
              WHEN OTHERS THEN
                pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
                  p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
                  ,p_ntraza_in          => 1189
                  ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                  ,p_usuario_in         => p_usuario_in
                  ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
                );
              END valida_null;

              <<valida_tipo_dato>>
              BEGIN
              IF p_nombre_tabla_in = c_nombre_tabla_ventas_diarias AND i_idx_info = c_info_col_tipdoc_ventas OR
                 (p_nombre_tabla_in = c_nombre_tabla_facturacion AND i_idx_info = c_info_col_tipdoc_facturacion) THEN
              --
              v_tipo_documento_iaxis := fu_homologa_tipo_doc(p_info_cargue_in(i_idx_info));
                    --
               v_correcto_tipo_dato := fu_correcto_tipo_dato(
                    p_nombre_tabla_in
                    ,t_cols_id(idx)         --Identificador de la columna
                    ,v_tipo_documento_iaxis    --Valor del campo en el cargue
                    ,v_clave
                    ,v_codigo_error);
              --
              ELSE
              --
                v_correcto_tipo_dato := fu_correcto_tipo_dato(
                    p_nombre_tabla_in
                   ,t_cols_id(idx)           --Identificador de la columna
                   ,p_info_cargue_in(i_idx_info)    --Valor del campo en el cargue
                   ,v_clave
                   ,v_codigo_error);
              --
              END IF;

                --Se valida si el valor es valido con el tipo de dato de la columna
                IF b_validar_tipo_dato AND v_correcto_tipo_dato = c_n THEN
                --
                  --Se agrega el error a la observacion
                  v_observa_error := fu_adiciona_error(v_codigo_error, v_observa_error, t_typ_tabla(v_clave).nombre_columna);
                  b_tiene_error := TRUE;
                --
                END IF;
                --
              EXCEPTION
              WHEN OTHERS THEN
                pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
                  p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
                  ,p_ntraza_in          => 1231
                  ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                  ,p_usuario_in         => p_usuario_in
                  ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
                );
              END valida_tipo_dato;

            --Si la columna de la tabla existe en el type, se valida si el dato existe parametrizado en msv_tb_parametro
              IF (t_typ_par.EXISTS(v_clave) AND p_info_cargue_in(i_idx_info) IS NOT NULL) THEN
              --
                IF t_typ_par(v_clave).tipo_validacion = c_tipo_val_fecha_mayor_act THEN
                --
                  IF (v_correcto_tipo_dato =  c_s AND TO_DATE(p_info_cargue_in(i_idx_info),c_formato_dd_mm_yyyy) > TRUNC(SYSDATE)) THEN
                  --
                    --Se agrega el error a la observacion
                    v_observa_error := fu_adiciona_error(c_cod_error_fecha_no_val, v_observa_error, t_typ_tabla(v_clave).nombre_columna);
                  --
                  END IF;
                --
                ELSIF fu_existe_parametro_grupo(t_typ_par(v_clave).nombre_grupo, p_info_cargue_in(i_idx_info)) = c_n THEN
                  --Se agrega el error a la observacion
                  v_observa_error := fu_adiciona_error(c_cod_error_vlr_no_param, v_observa_error, t_typ_tabla(v_clave).nombre_columna);
                END IF;
              --
              END IF;
          --
          <<valida_codigo_dane>>
              BEGIN
                IF (p_nombre_tabla_in = c_nombre_tabla_ventas_diarias AND c_info_col_codciudad_ventas = i_idx_info
                   OR (p_nombre_tabla_in = c_nombre_tabla_facturacion AND c_info_col_codciudad_facturac = i_idx_info))
                AND pac_msv_utilidades.fu_existe_ciudad_x_dpto(
                        p_info_cargue_in(i_idx_info))  = c_n THEN
                  --Se agrega el error a la observacion
                  v_codigo_error := c_cod_error_no_ciudad;
                  v_observa_error := fu_adiciona_error(v_codigo_error, v_observa_error, t_typ_tabla(v_clave).nombre_columna);
                  b_tiene_error := TRUE;
                END IF;
              EXCEPTION
              WHEN OTHERS THEN
                  pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
                    p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
                    ,p_ntraza_in          => 1273
                    ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,p_usuario_in         => p_usuario_in
                    ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
                  );
              END valida_codigo_dane;
          --
          <<valida_numero>>
              BEGIN
                IF p_nombre_tabla_in = c_nombre_tabla_ventas_diarias and c_info_col_numtel_ventas = i_idx_info AND pac_msv_utilidades.fu_es_numero(p_info_cargue_in(i_idx_info)) = false THEN
                  --Se agrega el error a la observacion
                  v_codigo_error := c_cod_error_valor_no_valido;
                  v_observa_error := fu_adiciona_error(v_codigo_error, v_observa_error, t_typ_tabla(v_clave).nombre_columna);
                  b_tiene_error := TRUE;
                END IF;
              EXCEPTION
              WHEN OTHERS THEN
                  pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
                    p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
                    ,p_ntraza_in          => 1273
                    ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,p_usuario_in         => p_usuario_in
                    ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
                  );
              END valida_numero;
          --
          <<valida_valor_asegurado>>
              BEGIN
                IF (p_nombre_tabla_in = c_nombre_tabla_ventas_diarias and c_info_col_valoraseg_ventas = i_idx_info
                     or p_nombre_tabla_in = c_nombre_tabla_facturacion and c_info_col_valoraseg_facturac = i_idx_info)
                AND pac_msv_utilidades.fu_es_numero(p_info_cargue_in(i_idx_info)) = false THEN
                  --Se agrega el error a la observacion
                  v_codigo_error := c_cod_error_valor_no_valido;
                  v_observa_error := fu_adiciona_error(v_codigo_error, v_observa_error, t_typ_tabla(v_clave).nombre_columna);
                  b_tiene_error := TRUE;
                END IF;
              EXCEPTION
              WHEN OTHERS THEN
                  pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
                    p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
                    ,p_ntraza_in          => 1273
                    ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,p_usuario_in         => p_usuario_in
                    ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
                  );
              END valida_valor_asegurado;
          --

          <<valida_tipo_de_Novedad>>
          -- cancelaciones
          BEGIN
             IF (p_nombre_tabla_in = c_nombre_tabla_cancelaciones and  c_info_col_tipo_novedad = i_idx_info) then
               IF p_info_cargue_in(i_idx_info) <> pac_msv_constantes.c_tipo_novedad_cancelacion THEN
                  v_codigo_error := c_cod_error_tipo_cancel;
                  v_observa_error := fu_adiciona_error(v_codigo_error, v_observa_error, t_typ_tabla(v_clave).nombre_columna);
                  b_tiene_error := TRUE;
               END IF;
             END IF;
             -- novedades
             IF (p_nombre_tabla_in = c_nombre_tabla_novedades and c_info_col_tipo_novedad = i_idx_info) then
               IF p_info_cargue_in(i_idx_info) NOT IN (pac_msv_constantes.c_tipo_novedad_cambio_vig,
                                                       pac_msv_constantes.c_tipo_novedad_cambio_venc,
                                                       pac_msv_constantes.c_tipo_novedad_cred_congel,
                                                       pac_msv_constantes.c_tipo_novedad_cambio_cred,
                                                       pac_msv_constantes.c_tipo_novedad_cambio_ref,
                                                       pac_msv_constantes.c_tipo_novedad_cambio_direc) THEN
                  v_codigo_error := c_cod_error_tipo_cancel;
                  v_observa_error := fu_adiciona_error(v_codigo_error, v_observa_error, t_typ_tabla(v_clave).nombre_columna);
                  b_tiene_error := TRUE;
               END IF;
             END IF;
          EXCEPTION
            WHEN OTHERS THEN
              pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
                    p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
                    ,p_ntraza_in          => 1440
                    ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,p_usuario_in         => p_usuario_in
                    ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
                  );
          END valida_tipo_de_Novedad;
          --0001
          <<Valida_cambio_vigencia_poliza>>
          BEGIN
            NULL;
          END Valida_cambio_vigencia_poliza;
          --0002
          <<Valida_venci_cuota>>
          BEGIN
            NULL;
          END Valida_venci_cuota;
          --0003
          <<Valida_cread_congel>>
          BEGIN
            NULL;
          END Valida_cread_congel;
          --0004
          <<Valida_cambio_cread_recaudador>>
          BEGIN
            NULL;
          END Valida_cambio_cread_recaudador;
          --0005
          <<Valida_cambio_ref_garantia>>
          BEGIN
            NULL;
          END Valida_cambio_ref_garantia;
          --0006
          <<Valida_cambio_direccion>>
          BEGIN
            NULL;
          END Valida_cambio_direccion;

          i_idx_info := i_idx_info + 1;
          --
          END LOOP;
      EXCEPTION
      WHEN OTHERS THEN
        b_tiene_error := TRUE;
        p_observacion_proceso_out := 'Error validando las columnas de la tabla cargue';

        pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
                p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
                ,p_ntraza_in          => 1289
                ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                ,p_usuario_in         => p_usuario_in
                ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
              );
      END leer_cols;
  --
  END IF;

  IF NOT(b_tiene_error) AND v_observa_error IS NULL THEN
    p_indicador_proceso_out := pac_msv_constantes.c_respuesta_exitosa;
  ELSIF NOT(b_tiene_error) AND v_observa_error IS NOT NULL THEN
    p_indicador_proceso_out := pac_msv_constantes.c_exitosa_con_advertencia;
  ELSE
    v_observa_error := fu_adiciona_error(c_cod_error_no_estructura, v_observa_error, c_cod_estructura);
    p_indicador_proceso_out := pac_msv_constantes.c_fallo_error_datos;
  END IF;


  p_observacion_proceso_out := v_observa_error;
--
 EXCEPTION
 WHEN OTHERS THEN
    p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
    p_observacion_proceso_out := 'Error al validar el registro del cargue '||SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;

    pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
            p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
            ,p_ntraza_in          => 1330
            ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            ,p_usuario_in         => p_usuario_in
            ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
          );
END pr_valida_cargue_x_tipo;
--
PROCEDURE pr_gu_encabezado(
   p_id_cargue_in             IN   msv_tb_cargue_masivo.id%TYPE
  ,p_info_cargue_in           IN   pac_msv_utilidades.t_array
  ,p_usuario_in               IN   msv_tb_cargue_masivo.usuario_creacion%TYPE
  ,p_indicador_proceso_out    OUT  VARCHAR2
  ,p_observacion_proceso_out  OUT  VARCHAR2)
IS
/**************************************************************************
    NOMBRE:         pr_gu_encabezado
    TIPO:           Procedimiento
    PROPOSITO:      Procedimiento encargado de registrar el encabezado del cargue
    CREADO POR:     Company


    PARAMETROS DE ENTRADA:
    Nombre                      Tipo            Descripcion
    -------------------         --------        -----------------------
    p_id_cargue_in              NUMBER          Identificador de la tabla msv_tb_cargue_masivo,
                                                correspondiente al id del cargue
    p_info_cargue_in			t_array         Arreglo con la informacion a registrar
    p_usuario_in                VARCHAR2        Usuario que ejecuta el proceso

    PARAMETROS DE SALIDA:
    Nombre                      Tipo        Descripcion
    ---------                   --------    -----------------------------------
    p_indicador_proceso_out     VARCHAR     Indicador resultado del proceso
    p_observacion_proceso_out   VARCHAR     Texto con el restultado del proceso

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         13/03/2018  Company                Creacion y documentacion de funcion

***************************************************************************/
  ----------------------------------------------------------------------------
  --  SECCION CONSTANTES
  ----------------------------------------------------------------------------
  c_nombre_procedimiento      VARCHAR2(30) DEFAULT 'pr_gu_encabezado';

  -----------------------------------------------------------------------------
  -- SECCION VARCHAR
  -----------------------------------------------------------------------------
  v_tipo_documento_iaxis      VARCHAR2(10);

  -----------------------------------------------------------------------------
  -- SECCION NUMBER
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION CURSORES
  -----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION %TYPE
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION %ROWTYPE
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION PROCEDIMIENTOS/FUNCIONES PRIVADAS
  ----------------------------------------------------------------------------
BEGIN
   p_indicador_proceso_out   := pac_msv_constantes.c_respuesta_exitosa;


    NULL;
   EXCEPTION
   WHEN OTHERS THEN
      p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
	  p_observacion_proceso_out := SQLCODE || ' @ ' ||SQLERRM;
      pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
		 p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
		,p_ntraza_in          => 2339
		,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
		,p_usuario_in         => p_usuario_in
		,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
      );
END pr_gu_encabezado;
--
PROCEDURE pr_valida_encabezado(
  p_tipo_cargue_in            IN   msv_tb_cargue_masivo.tipo%TYPE
  ,p_info_cargue_in           IN   pac_msv_utilidades.t_array
  ,p_cant_registros_in        IN   NUMBER
  ,p_usuario_in               IN   msv_tb_cargue_masivo.usuario_creacion%TYPE
  ,p_indicador_proceso_out    OUT  VARCHAR2
  ,p_observacion_proceso_out  OUT  VARCHAR2)
IS
/**************************************************************************
    NOMBRE:         pr_valida_encabezado
    TIPO:           Procedimiento
    PROPOSITO:      Procedimiento encargado de validar el primer registro del cargue
    CREADO POR:     Company


    PARAMETROS DE ENTRADA:
    Nombre                      Tipo            Descripcion
    -------------------         --------        -----------------------
    p_tipo_cargue_in            VARCHAR2        Contiene el tipo de cargue que se va realizar
    p_info_cargue_in            TABLE OF
                                VARCHAR2(32767) Arreglo con la informacion de cada registro
    p_cant_registros_in         NUMBER          Numero de registros de detalle que tiene el archivo
    p_usuario_in                VARCHAR2        Identificador del usuario que realiza el proceso

    PARAMETROS DE SALIDA:
    Nombre                      Tipo        Descripcion
    ---------                   --------    -----------------------------------
    p_indicador_proceso_out     VARCHAR     Indicador resultado del proceso
    p_observacion_proceso_out   VARCHAR     Texto con el restultado del proceso

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         05/04/2018  Company               Creacion y documentacion de funcion

***************************************************************************/
  ----------------------------------------------------------------------------
  --  SECCION CONSTANTES
  ----------------------------------------------------------------------------
  c_nombre_procedimiento        CONSTANT VARCHAR2(30) DEFAULT 'pr_valida_encabezado';

  c_cod_id_columna_ventas         CONSTANT VARCHAR2(30) DEFAULT 'IDS_COL_TB_VIDA';
  c_cod_id_columna_vida_facturac  CONSTANT VARCHAR2(30) DEFAULT 'IDS_COL_TB_VIDA_BENE';

  -- Ventas diarias
  c_info_enc_tipreg_ventas      CONSTANT NUMBER DEFAULT 0;
  c_info_enc_cantreg_ventas     CONSTANT NUMBER DEFAULT 2;
  c_info_enc_asegorigen_ventas  CONSTANT NUMBER DEFAULT 3;

  -- Facturacion
  c_info_enc_tipreg_facturacion     CONSTANT NUMBER DEFAULT 0;
  c_info_enc_cantreg_facturacion    CONSTANT NUMBER DEFAULT 2;
  c_info_enc_asegorigen_facturac    CONSTANT NUMBER DEFAULT 3;

  -----------------------------------------------------------------------------
  -- SECCION VARCHAR
  -----------------------------------------------------------------------------
  v_codigo_error             VARCHAR2(100);
  v_observa_error            VARCHAR2(4000);
  v_parametro                msv_tb_parametro.valor%TYPE;

  -----------------------------------------------------------------------------
  -- SECCION NUMBER
  -----------------------------------------------------------------------------
  n_cant_registros_in       NUMBER;
  -----------------------------------------------------------------------------
  -- SECCION CURSORES
  -----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION %TYPE
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION BOOLEAN
  ----------------------------------------------------------------------------
  b_tiene_error              BOOLEAN DEFAULT FALSE;
  ----------------------------------------------------------------------------
  -- SECCION %ROWTYPE
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION EXCEPCIONES
  ----------------------------------------------------------------------------

  BEGIN

  v_observa_error := '';
  n_cant_registros_in := p_cant_registros_in - 1;
     v_parametro := pac_msv_utilidades.fu_valor_parametro(
				  c_cod_aseg_origen
				  ,c_grupo_cargue_masivo);


            <<valida_aseguradora>>
              BEGIN
              IF NOT(p_info_cargue_in(c_info_enc_asegorigen_ventas) = v_parametro
                    or p_info_cargue_in(c_info_enc_asegorigen_facturac) = v_parametro) THEN
              --
              v_codigo_error := c_cod_error_aseguradora;
              v_observa_error := fu_adiciona_error(v_codigo_error, v_observa_error, c_cod_estructura);
              b_tiene_error := TRUE;
              END IF;
                EXCEPTION
              WHEN OTHERS THEN
                  pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
                    p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
                    ,p_ntraza_in          => 1273
                    ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,p_usuario_in         => p_usuario_in
                    ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
                  );
              END valida_aseguradora;

        IF NOT(b_tiene_error) AND v_observa_error IS NULL THEN
          p_indicador_proceso_out := pac_msv_constantes.c_respuesta_exitosa;
        ELSIF NOT(b_tiene_error) AND v_observa_error IS NOT NULL THEN
          p_indicador_proceso_out := pac_msv_constantes.c_exitosa_con_advertencia;
        ELSE
          v_observa_error := fu_adiciona_error(c_cod_error_no_estructura, v_observa_error, c_cod_estructura);
          p_indicador_proceso_out := pac_msv_constantes.c_fallo_error_datos;
        END IF;
        --

        p_observacion_proceso_out := v_observa_error;
        --
  EXCEPTION
 WHEN OTHERS THEN
    p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
    p_observacion_proceso_out := 'Error al validar el registro del cargue '||SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;

    pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
            p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
            ,p_ntraza_in          => 1330
            ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            ,p_usuario_in         => p_usuario_in
            ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
          );
END pr_valida_encabezado;
--
PROCEDURE pr_valida_cargue_vida(
  p_info_cargue_in            IN   pac_msv_utilidades.t_array
  ,p_usuario_in               IN   msv_tb_cargue_masivo.usuario_creacion%TYPE
  ,p_indicador_proceso_out    OUT  VARCHAR2
  ,p_observacion_proceso_out  OUT  VARCHAR2)
IS
/**************************************************************************
    NOMBRE:         pr_valida_cargue_vida
    TIPO:           Procedimiento
    PROPOSITO:      Procedimiento encargado de validar el registro del cargue
                    masivo de VIDA
    CREADO POR:     Company


    PARAMETROS DE ENTRADA:
    Nombre                      Tipo            Descripcion
    -------------------         --------        -----------------------
    p_info_cargue_in            TABLE OF
                                VARCHAR2(32767) Arreglo con la informacion de cada registro
    p_usuario_in                VARCHAR2        Identificador del usuario que realiza el proceso

    PARAMETROS DE SALIDA:
    Nombre                      Tipo        Descripcion
    ---------                   --------    -----------------------------------
    p_indicador_proceso_out     VARCHAR     Indicador resultado del proceso
    p_observacion_proceso_out   VARCHAR     Texto con el restultado del proceso

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         06/12/2017  Company                Creacion y documentacion de funcion

***************************************************************************/
  ----------------------------------------------------------------------------
  --  SECCION CONSTANTES
  ----------------------------------------------------------------------------
  c_nombre_procedimiento        CONSTANT VARCHAR2(30) DEFAULT 'pr_valida_cargue_vida';
  c_id_plan_mod_b               CONSTANT NUMBER DEFAULT 82;
  c_id_promotor                 CONSTANT NUMBER DEFAULT 83;
  c_id_certificado              CONSTANT NUMBER DEFAULT 84;
  c_id_primer_benef             CONSTANT NUMBER DEFAULT 20;

  c_cod_id_columna_vida         CONSTANT VARCHAR2(30) DEFAULT 'IDS_COL_TB_VIDA';
  c_cod_id_columna_vida_benef   CONSTANT VARCHAR2(30) DEFAULT 'IDS_COL_TB_VIDA_BENE';
  c_cod_id_columna_vida_depen   CONSTANT VARCHAR2(30) DEFAULT 'IDS_COL_TB_VIDA_BEDP';

  --Id de la columna del tipo de documento en la tabla <<GSE_TB_VIDA_DETALLE>>
  c_id_col_ciudad_vida          CONSTANT NUMBER DEFAULT 8;
  c_id_col_periodicidad_vida    CONSTANT NUMBER DEFAULT 13;

  --Id de la columna de Ciudad en la tabla <<GSE_TB_VIDA_BENEFICIARIOS>>
  c_id_col_ciudad_vida_benef    CONSTANT NUMBER DEFAULT 8;
  c_id_col_porcentaje_benef     CONSTANT NUMBER DEFAULT 18;

  -----------------------------------------------------------------------------
  -- SECCION VARCHAR
  -----------------------------------------------------------------------------
  v_obs_error                VARCHAR2(4000);
  v_obs_error_benef          VARCHAR2(2000);
  v_codigo_error             VARCHAR2(100);
  v_parametro                msv_tb_parametro.valor%TYPE;
  --Contendra la clave en el type tipo table
  v_clave                    VARCHAR2(70);

  v_nombre_tabla             VARCHAR2(30);
  v_codigo_id_columnas       VARCHAR2(30);
  v_codigo_tmp               msv_tb_parametro.valor%TYPE;
  v_grupo                    msv_tb_parametro.grupo%TYPE;
  v_correcto_tipo_dato       VARCHAR2(1) DEFAULT c_n;

  -----------------------------------------------------------------------------
  -- SECCION NUMBER
  -----------------------------------------------------------------------------
  n_posi_campo              NUMBER;
  n_total_benef_correcto    NUMBER DEFAULT 0;
  n_total_porcentaje        NUMBER DEFAULT 0;

  -----------------------------------------------------------------------------
  -- SECCION CURSORES
  -----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION %TYPE
  ----------------------------------------------------------------------------
  --Contendra en un array los id de las columnas donde se cargaran los datos
  --del cargue
  t_cols_id                 pac_msv_utilidades.t_array;
  t_cols_id_beneficiarios   pac_msv_utilidades.t_array;
  t_cols_id_dependiente     pac_msv_utilidades.t_array;

  ----------------------------------------------------------------------------
  -- SECCION BOOLEAN
  ----------------------------------------------------------------------------
  b_tiene_error              BOOLEAN DEFAULT FALSE;
  b_benef_error              BOOLEAN DEFAULT FALSE;
  b_validar_tipo_dato        BOOLEAN DEFAULT FALSE;

  ----------------------------------------------------------------------------
  -- SECCION %ROWTYPE
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION EXCEPCIONES
  ----------------------------------------------------------------------------

BEGIN

  --Se arma type con clave <<NOMBRE_TABLA_COLUMNA_ID>>, que va contener las columnas a validar por tabla
  --el cual se usara para validar si el dato existe parametrizado segun el grupo dentro del type
  pr_inicia_type_parametro();

  ----------------------------------------------------------------------------
  --     valida campos de  GSE_TB_VIDA_DETALLE
  ----------------------------------------------------------------------------
  --1. Se validan los campos de la tabla  <<GSE_TB_VIDA_DETALLE>> inicialmente
  v_codigo_id_columnas := c_cod_id_columna_vida;
  v_nombre_tabla       := c_nombre_tabla_vida;

  v_parametro := pac_msv_utilidades.fu_valor_parametro(
                  v_codigo_id_columnas
                  ,c_grupo_cargue_masivo);


  --Se obtienen los id de las columnas separados
  t_cols_id := pac_msv_utilidades.fu_split(v_parametro, pac_msv_constantes.c_caracter_coma);
  v_obs_error := '';

  --Se obtienen los id de las columnas de vida beneficiarios <<GSE_TB_VIDA_BENEFICIARIOS>>  para beneficiarios
  v_parametro := pac_msv_utilidades.fu_valor_parametro(
                  c_cod_id_columna_vida_benef
                  ,c_grupo_cargue_masivo);

  t_cols_id_beneficiarios := pac_msv_utilidades.fu_split(v_parametro, pac_msv_constantes.c_caracter_coma);

  --Se obtienen los id de las columnas de vida beneficiarios <<GSE_TB_VIDA_BENEFICIARIOS>>  para dependiente
  v_parametro := pac_msv_utilidades.fu_valor_parametro(
                  c_cod_id_columna_vida_depen
                  ,c_grupo_cargue_masivo);

  t_cols_id_dependiente := pac_msv_utilidades.fu_split(v_parametro, pac_msv_constantes.c_caracter_coma);

  --Se verifica que la estructura del archivo corresponda con la esperada
  IF ((t_cols_id.COUNT + t_cols_id_beneficiarios.COUNT*10 + t_cols_id_dependiente.COUNT) != p_info_cargue_in.COUNT) THEN
  --
    --v_obs_error := fu_adiciona_error(c_cod_error_no_estructura, v_obs_error, c_cod_estructura);
    b_tiene_error := TRUE;
  --
  ELSE
  --
      <<leer_cols_vida>>
      BEGIN
        --Se recorre la lista de id de columnas a validar
        FOR idx IN t_cols_id.first .. t_cols_id.last
        LOOP
            n_posi_campo := idx;

            --Si es la penultima columna a validar, se asigna el id de la posicion del campo PLAN_MODULO_B
            IF (idx = ((t_cols_id.last)-2) ) THEN
              n_posi_campo := c_id_plan_mod_b;
            END IF;
            --Si es la penultima columna a validar, se asigna el id de la posicion del campo PROMOTOR
            IF (idx = ((t_cols_id.last)-1) ) THEN
               n_posi_campo := c_id_promotor;
            END IF;
            --Si es la ultima columna a validar, se asigna el id de la posicion del campo CERTIFICADO
            IF (idx = t_cols_id.last) THEN
               n_posi_campo := c_id_certificado;
            END IF;


            --Se arma una clave con el nombre de la tabla y el id de la columna
            v_clave := v_nombre_tabla||c_char_underline||t_cols_id(idx);

            --Se cambia el indicador para no validar el tipo de dato con fu_correcto_tipo_dato
            IF t_cols_id(idx) = c_id_col_tipo_doc_vida THEN
            --
              b_validar_tipo_dato := FALSE;

              --Se consulta la homologacion del tipo de documento con iaxis, sino tiene se genera error
              IF  fu_homologa_tipo_doc(p_info_cargue_in(n_posi_campo)) IS NULL THEN
                b_tiene_error := TRUE;
              END IF;
            --
            END IF;


            <<valida_null>>
            BEGIN
              --Se valida si la columna permite o no null, con respecto al valor recibido
              IF  fu_correcto_null(
                      v_nombre_tabla
                     ,t_cols_id(idx)                     --Identificador de la columna
                     ,p_info_cargue_in(n_posi_campo)    --Valor del campo en el cargue
                     ,v_clave
                     ,v_codigo_error) = c_n THEN
                --Se agrega el error a la observacion
                v_obs_error := fu_adiciona_error(v_codigo_error, v_obs_error, t_typ_tabla(v_clave).nombre_columna);
                b_tiene_error := TRUE;
              END IF;
            EXCEPTION
            WHEN OTHERS THEN
              pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
                p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
                ,p_ntraza_in          => 1534
                ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                ,p_usuario_in         => p_usuario_in
                ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
              );
            END valida_null;

            <<valida_tipo_dato>>
            BEGIN
              v_correcto_tipo_dato :=
                fu_correcto_tipo_dato(
                      v_nombre_tabla
                     ,t_cols_id(idx)                  --Identificador de la columna
                     ,p_info_cargue_in(n_posi_campo) --Valor del campo en el cargue
                     ,v_clave
                     ,v_codigo_error);

              --Se valida si el valor es valido con el tipo de dato de la columna
              IF b_validar_tipo_dato AND v_correcto_tipo_dato = c_n THEN
              --
                --Se agrega el error a la observacion
                v_obs_error := fu_adiciona_error(v_codigo_error, v_obs_error, t_typ_tabla(v_clave).nombre_columna);
                b_tiene_error := TRUE;
              --
              END IF;

              --Si el tipo de dato es valido y la columna es PERIODICIDAD se valida si corresponde con el valor parametrizado
              IF v_correcto_tipo_dato = c_s AND t_cols_id(idx) = c_id_col_periodicidad_vida THEN
              --
                  --Se consulta el valor parametrizado para la periodicidad
                  v_parametro := pac_msv_utilidades.fu_valor_parametro(
                    'PERIODICIDAD'
                    ,c_grupo_cargue_masivo);

                  IF p_info_cargue_in(idx) != v_parametro THEN
                      --Se agrega el error a la observacion
                      v_obs_error := fu_adiciona_error(c_cod_error_valor_no_valido, v_obs_error, t_typ_tabla(v_clave).nombre_columna);
                  END IF;
              --
              END IF;
            EXCEPTION
            WHEN OTHERS THEN
              pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
                p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
                ,p_ntraza_in          => 1577
                ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                ,p_usuario_in         => p_usuario_in
                ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
              );
            END valida_tipo_dato;

            --Si es la columna CIUDAD se valida si existe en iAxis
            IF (t_cols_id(idx) = c_id_col_ciudad_vida) THEN
            --
              IF pac_msv_utilidades.fu_existe_ciudad_x_dpto(p_info_cargue_in(idx)) = c_n THEN
                  --Se agrega el error a la observacion
                  v_obs_error := fu_adiciona_error(c_cod_error_no_ciudad, v_obs_error, t_typ_tabla(v_clave).nombre_columna);
              END IF;
            --
            --Si la columna de la tabla existe en el type, se valida si el dato existe parametrizado en msv_tb_parametro
            ELSIF (t_typ_par.EXISTS(v_clave) AND p_info_cargue_in(n_posi_campo) IS NOT NULL) THEN
            --
                IF t_typ_par(v_clave).tipo_validacion = c_tipo_val_fecha_mayor_act THEN
                --
                  IF (v_correcto_tipo_dato =  c_s AND TO_DATE(p_info_cargue_in(idx),c_formato_dd_mm_yyyy) > TRUNC(SYSDATE)) THEN
                  --
                    --Se agrega el error a la observacion
                    v_obs_error := fu_adiciona_error(c_cod_error_fecha_no_val, v_obs_error, t_typ_tabla(v_clave).nombre_columna);
                  --
                  END IF;
               --
               ELSIF  fu_existe_parametro_grupo(t_typ_par(v_clave).nombre_grupo, p_info_cargue_in(n_posi_campo)) = c_n THEN
                  --Se agrega el error a la observacion
                  v_obs_error := fu_adiciona_error(c_cod_error_vlr_no_param, v_obs_error, t_typ_tabla(v_clave).nombre_columna);
              END IF;
            END IF;

            --Se valida la longitud del valor recibido, es valido con respecto a la columna
            <<valida_longitud>>
            BEGIN
              IF p_info_cargue_in(n_posi_campo) IS NOT NULL AND fu_cumple_longitud(
                      v_nombre_tabla
                     ,t_cols_id(idx)                     --Identificador de la columna
                     ,p_info_cargue_in(n_posi_campo)    --Valor del campo en el cargue
                     ,v_clave
                     ,v_codigo_error)  = c_n THEN
                --Se agrega el error a la observacion
                v_obs_error := fu_adiciona_error(v_codigo_error, v_obs_error, t_typ_tabla(v_clave).nombre_columna);
                b_tiene_error := TRUE;
              END IF;
            EXCEPTION
            WHEN OTHERS THEN
                pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
                  p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
                  ,p_ntraza_in          => 1618
                  ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                  ,p_usuario_in         => p_usuario_in
                  ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
                );
            END valida_longitud;
        END LOOP;
      END leer_cols_vida;

      ----------------------------------------------------------------------------
      --     valida campos de  GSE_TB_VIDA_BENEFICIARIOS
      ----------------------------------------------------------------------------
      v_nombre_tabla       := c_nombre_tabla_vida_benef;


      --Se obtienen los id de las columnas separados
      t_cols_id := t_cols_id_beneficiarios;
      n_posi_campo := c_id_primer_benef;

      <<leer_cols_vida_benef>>
      BEGIN
        --Se recorre hasta 11 veces, para validar 10 beneficiarios y 1 dependiente
        --por lo menos debe existir un beneficiario
        FOR idx_benef IN 1..11
        LOOP
            --Se inicializa la variable
            b_benef_error := FALSE;
            b_validar_tipo_dato := TRUE;
            v_obs_error_benef := NULL;

            --Cuando sea el ultimo recorrido se cambian los id de columnas a validar
            --para validar los campos de la persona dependiente
            IF idx_benef = 11 THEN
               --Se obtienen los id de las columnas separados
               t_cols_id := t_cols_id_dependiente;
            END IF;


            --Se recorren los id de las columnas a validar de los 10 beneficiarios con
            --respecto a la informacion del archivo
            FOR idx IN t_cols_id.first .. t_cols_id.last
            LOOP
            --
              --Valida que el campo <NOMBRE>, si esta vacio no valida el resto de campos del beneficiario
              IF idx = 0 AND p_info_cargue_in(n_posi_campo) IS NULL THEN
                IF idx_benef != 11 THEN
                --
                  --Se inicializa la variable
                  b_benef_error := NULL;
                  n_posi_campo := n_posi_campo + 5;
                --
                END IF;
                EXIT;
              END IF;

              --Se arma una clave con el nombre de la tabla y el id de la columna
              v_clave := v_nombre_tabla||c_char_underline||t_cols_id(idx);

              <<valida_null>>
              BEGIN
                --Se valida si la columna permite o no null, con respecto al valor recibido
                IF fu_correcto_null(
                        v_nombre_tabla
                       ,t_cols_id(idx)                     --Identificador de la columna
                       ,p_info_cargue_in(n_posi_campo)     --Valor del campo en el cargue
                       ,v_clave
                       ,v_codigo_error) = c_n THEN
                  --Se agrega el error a la observacion
                  v_obs_error_benef := fu_adiciona_error(v_codigo_error, v_obs_error_benef, t_typ_tabla(v_clave).nombre_columna);
                  b_benef_error := TRUE;
                END IF;
              EXCEPTION
              WHEN OTHERS THEN
                pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
                  p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
                  ,p_ntraza_in          => 1693
                  ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                  ,p_usuario_in         => p_usuario_in
                  ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
                );
              END valida_null;

              --Se cambia el indicador para no validar el tipo de dato con fu_correcto_tipo_dato
              IF idx_benef = 11 AND t_cols_id(idx) = c_id_col_tipo_doc_vida_dep THEN
              --
                b_validar_tipo_dato := FALSE;
              --
              END IF;

              <<valida_tipo_dato>>
              BEGIN
                v_correcto_tipo_dato := fu_correcto_tipo_dato(
                        v_nombre_tabla
                       ,t_cols_id(idx)                  --Identificador de la columna
                       ,p_info_cargue_in(n_posi_campo) --Valor del campo en el cargue
                       ,v_clave
                       ,v_codigo_error);

                --Se valida si el valor es valido con el tipo de dato de la columna
                IF b_validar_tipo_dato AND v_correcto_tipo_dato = c_n THEN
                --
                  --Se agrega el error a la observacion
                  v_obs_error_benef := fu_adiciona_error(v_codigo_error, v_obs_error_benef, t_typ_tabla(v_clave).nombre_columna);
                  b_benef_error := TRUE;
                --
                ELSE
                --
                    --Si es un beneficiario, se suma el valor del porcentaje
                    IF (idx_benef != 11 AND t_cols_id(idx) = c_id_col_porcentaje_benef) THEN
                    --
                      n_total_porcentaje := NVL(TO_NUMBER(p_info_cargue_in(n_posi_campo)),0) + n_total_porcentaje;
                    --
                    END IF;
                --
                END IF;
              EXCEPTION
              WHEN OTHERS THEN
                pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
                  p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
                  ,p_ntraza_in          => 1741
                  ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                  ,p_usuario_in         => p_usuario_in
                  ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
                );
              END valida_tipo_dato;



              --Si la columna de la tabla existe en el type, se valida si el dato existe parametrizado en msv_tb_parametro
              IF (t_typ_par.EXISTS(v_clave) AND p_info_cargue_in(n_posi_campo) IS NOT NULL) THEN
              --
                IF t_typ_par(v_clave).tipo_validacion = c_tipo_val_fecha_mayor_act THEN
                --
                  IF (v_correcto_tipo_dato =  c_s AND TO_DATE(p_info_cargue_in(n_posi_campo),c_formato_dd_mm_yyyy) > TRUNC(SYSDATE)) THEN
                  --
                    --Se agrega el error a la observacion
                    v_obs_error_benef := fu_adiciona_error(c_cod_error_fecha_no_val, v_obs_error_benef, t_typ_tabla(v_clave).nombre_columna);
                  --
                  END IF;
                --
                ELSIF fu_existe_parametro_grupo(t_typ_par(v_clave).nombre_grupo, p_info_cargue_in(n_posi_campo)) = c_n THEN
                    --Se agrega el error a la observacion
                    v_obs_error_benef := fu_adiciona_error(c_cod_error_vlr_no_param, v_obs_error_benef, t_typ_tabla(v_clave).nombre_columna);
                END IF;
              --Si es la columna <<CIUDAD>> se valida si existe en iAxis
              ELSIF (v_correcto_tipo_dato = c_s AND idx_benef = 11 AND t_cols_id(idx) = c_id_col_ciudad_vida_benef) THEN
              --
                IF pac_msv_utilidades.fu_existe_ciudad_x_dpto(p_info_cargue_in(n_posi_campo)) = c_n THEN
                    --Se agrega el error a la observacion
                    v_obs_error_benef := fu_adiciona_error(c_cod_error_no_ciudad, v_obs_error_benef, t_typ_tabla(v_clave).nombre_columna);
                END IF;
              --
              END IF;

              --Se valida la longitud del valor recibido, es valido con respecto a la columna
              <<valida_longitud>>
              BEGIN
                IF p_info_cargue_in(n_posi_campo) IS NOT NULL AND fu_cumple_longitud(
                        v_nombre_tabla
                       ,t_cols_id(idx)                     --Identificador de la columna
                       ,p_info_cargue_in(n_posi_campo)    --Valor del campo en el cargue
                       ,v_clave
                       ,v_codigo_error)  = c_n THEN
                  --Se agrega el error a la observacion
                  v_obs_error_benef := fu_adiciona_error(v_codigo_error, v_obs_error_benef, t_typ_tabla(v_clave).nombre_columna);
                  b_benef_error := TRUE;

                END IF;
              EXCEPTION
              WHEN OTHERS THEN
                  pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
                    p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
                    ,p_ntraza_in          => 1785
                    ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                    ,p_usuario_in         => p_usuario_in
                    ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
                  );
              END valida_longitud;

              --Se incrementa en uno la posicion, para validar el siguiente campo
              n_posi_campo := n_posi_campo +1;
            --Fin del recorrido de las columnas de la tabla a validar
            END LOOP;

            IF v_obs_error_benef IS NOT NULL THEN
              SELECT DECODE(v_obs_error,NULL,SUBSTR(v_obs_error_benef,1,4000),SUBSTR(v_obs_error||';'||v_obs_error_benef,1,4000))
              INTO v_obs_error
              FROM DUAL;
            END IF;

            --Valida si el beneficiario tiene error
            IF b_benef_error THEN
              b_tiene_error := TRUE;
            ELSIF (idx_benef != 11  AND b_benef_error = FALSE) THEN
              n_total_benef_correcto := n_total_benef_correcto + 1;
            END IF;

            --Fin del recorrido de los 10 beneficiarios y un dependiente
        END LOOP;



        --Valida que exista por lo menos un beneficiario
        IF n_total_benef_correcto = 0 THEN
          b_tiene_error := TRUE;
          v_obs_error := fu_adiciona_error(c_cod_error_no_tiene_benef, v_obs_error, 'BENEFICIARIO');
        END IF;

      EXCEPTION
      WHEN OTHERS THEN
        b_tiene_error := TRUE;
        p_observacion_proceso_out := 'Error validando las columnas de la tabla cargue VIDA';

        pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
                p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
                ,p_ntraza_in          => 1829
                ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                ,p_usuario_in         => p_usuario_in
                ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
              );
      END leer_cols_vida_benef;
  -- Fin validar estructura del archivo
  END IF;



  --Valida que el porcentaje total sea 100% entre todos los beneficiarios
  IF n_total_porcentaje != 100 THEN
    v_obs_error := fu_adiciona_error(c_cod_error_porcentaje_100, v_obs_error, 'PORCENTAJE');
  END IF;

  IF NOT(b_tiene_error) AND v_obs_error IS NULL THEN
    p_indicador_proceso_out := pac_msv_constantes.c_respuesta_exitosa;
  ELSIF NOT(b_tiene_error) AND v_obs_error IS NOT NULL THEN
    p_indicador_proceso_out := pac_msv_constantes.c_exitosa_con_advertencia;
  ELSIF b_tiene_error Then
    v_obs_error := fu_adiciona_error(c_cod_error_no_estructura, v_obs_error, c_cod_estructura);
    p_indicador_proceso_out := pac_msv_constantes.c_fallo_error_datos;
  END IF;

  p_observacion_proceso_out := v_obs_error;

--
 EXCEPTION
 WHEN OTHERS THEN
    p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
    p_observacion_proceso_out := 'Error al validar el registro del cargue VIDA ';

    pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
            p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
            ,p_ntraza_in          => 1866
            ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            ,p_usuario_in         => p_usuario_in
            ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
          );
END pr_valida_cargue_vida;

PROCEDURE pr_valida_cargue_masivo(
   p_tipo_cargue_in            IN   msv_tb_cargue_masivo.tipo%TYPE
  ,p_info_cargue_in           IN   pac_msv_utilidades.t_array
  ,p_usuario_in               IN   msv_tb_cargue_masivo.usuario_creacion%TYPE
  ,p_indicador_proceso_out    OUT  VARCHAR2
  ,p_observacion_proceso_out  OUT  VARCHAR2)
IS
/**************************************************************************
    NOMBRE:         pr_valida_cargue_masivo
    TIPO:           Procedimiento
    PROPOSITO:      Procedimiento encargado de procesar el cargue masivo
    CREADO POR:     Company


    PARAMETROS DE ENTRADA:
    Nombre                      Tipo            Descripcion
    -------------------         --------        -----------------------
    p_tipo_cargue_in            NUMBER          Tipo de cargue, Ventas Diarias, Facturacion, Otros
    p_array_info_cargue_in      TABLE OF
                                VARCHAR2(32767) Arreglo con la informacion de cada registro

    PARAMETROS DE SALIDA:
    Nombre                      Tipo        Descripcion
    ---------                   --------    -----------------------------------
    p_indicador_proceso_out     VARCHAR     Indicador resultado del proceso
    p_observacion_proceso_out   VARCHAR     Texto con el restultado del proceso

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         13/03/2018  Company                 Creacion y documentacion de funcion

***************************************************************************/
  ----------------------------------------------------------------------------
  --  SECCION CONSTANTES
  ----------------------------------------------------------------------------
  c_nombre_procedimiento        CONSTANT VARCHAR2(30) DEFAULT 'pr_valida_cargue_masivo';
  -- Codigo parametrizado en MSV_TB_PARAMETRO GRUPO = GR_CARGUE_MASIVO
  c_cod_id_columna_vtas_diarias CONSTANT VARCHAR2(30) DEFAULT 'IDS_COL_TB_VENTAS';

  c_cod_id_columna_facturacion  CONSTANT VARCHAR2(30) DEFAULT 'IDS_COL_TB_FACTURAC';

  c_cod_id_columna_novedades    CONSTANT VARCHAR2(30) DEFAULT 'IDS_COL_TB_NOVEDADES';

  c_cod_id_columna_renovaciones CONSTANT VARCHAR2(30) DEFAULT 'IDS_COL_TB_RENOVA';

  c_cod_id_columna_cancelaciones CONSTANT VARCHAR2(30) DEFAULT 'IDS_COL_TB_CANCELA';

  c_cod_id_columna_devoluciones  CONSTANT VARCHAR2(30) DEFAULT 'IDS_COL_TB_DEVOLU';

  c_cod_id_columna_novedades_720 CONSTANT VARCHAR2(30) DEFAULT 'LONG_COL_TB_NOVD_720';

  c_cod_id_columna_cancel_720    CONSTANT VARCHAR2(30) DEFAULT 'LONG_COL_TB_CANC_720';

  -----------------------------------------------------------------------------
  -- SECCION VARCHAR
  -----------------------------------------------------------------------------
  v_nombre_tabla             VARCHAR2(30);
  v_codigo_id_columnas       VARCHAR2(30);

  -----------------------------------------------------------------------------
  -- SECCION NUMBER
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION CURSORES
  -----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION %TYPE
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION %ROWTYPE
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION PROCEDIMIENTOS/FUNCIONES PRIVADAS
  ----------------------------------------------------------------------------

BEGIN
    ---------------------------------------------------
    --   CARGUE VENTAS DIARIAS 411 o 720
    ---------------------------------------------------
  IF    p_tipo_cargue_in = pac_msv_constantes.c_tipo_cargue_ventas_diarias THEN
        v_codigo_id_columnas := c_cod_id_columna_vtas_diarias;
        v_nombre_tabla       := c_nombre_tabla_ventas_diarias;
    ---------------------------------------------------
    --   CARGUE FACTURACION 411 0 720
    ---------------------------------------------------
  ELSIF p_tipo_cargue_in = pac_msv_constantes.c_tipo_cargue_facturacion THEN
        v_codigo_id_columnas := c_cod_id_columna_facturacion;
        v_nombre_tabla       := c_nombre_tabla_facturacion;
    ---------------------------------------------------
    --   CARGUE NOVEDADES 411
    ---------------------------------------------------
  ELSIF p_tipo_cargue_in = pac_msv_constantes.c_tipo_cargue_novedades AND
        pac_msv_constantes.c_cod_prod_hogar_masivos = n_sproduc THEN
        v_codigo_id_columnas := c_cod_id_columna_novedades;
        v_nombre_tabla       := c_nombre_tabla_novedades;
    ---------------------------------------------------
    --   CARGUE RENOVACIONES
    ---------------------------------------------------
  ELSIF p_tipo_cargue_in = pac_msv_constantes.c_tipo_cargue_renovaciones THEN
        v_codigo_id_columnas := c_cod_id_columna_renovaciones;
        v_nombre_tabla       := c_nombre_tabla_renovaciones;
    ---------------------------------------------------
    --   CARGUE CANCELACIONES 411
    ---------------------------------------------------
  ELSIF p_tipo_cargue_in = pac_msv_constantes.c_tipo_cargue_cancelaciones AND
        pac_msv_constantes.c_cod_prod_hogar_masivos = n_sproduc THEN
        v_codigo_id_columnas := c_cod_id_columna_cancelaciones;
        v_nombre_tabla       := c_nombre_tabla_cancelaciones;
    ---------------------------------------------------
    --   CARGUE NOVEDADES 720
    ---------------------------------------------------
  ELSIF p_tipo_cargue_in = pac_msv_constantes.c_tipo_cargue_novedades AND
        pac_msv_constantes.c_cod_prod_incendio_colectivo = n_sproduc THEN
        v_codigo_id_columnas := c_cod_id_columna_novedades;
        v_nombre_tabla       := c_nombre_tabla_novedades;
    ---------------------------------------------------
    --   CARGUE CANCELACIONES 720
    ---------------------------------------------------
  ELSIF p_tipo_cargue_in = pac_msv_constantes.c_tipo_cargue_cancelaciones AND
        pac_msv_constantes.c_cod_prod_incendio_colectivo = n_sproduc  THEN
        v_codigo_id_columnas := c_cod_id_columna_cancelaciones;
        v_nombre_tabla       := c_nombre_tabla_cancelaciones;

  END IF;
  --Se valida segun el tipo de cargue
  pr_valida_cargue_x_tipo(
    p_info_cargue_in
    ,p_usuario_in
    ,v_nombre_tabla
    ,v_codigo_id_columnas
    ,p_indicador_proceso_out
    ,p_observacion_proceso_out
    );

--
 EXCEPTION
 WHEN OTHERS THEN
    p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
    p_observacion_proceso_out := 'Error al validar el cargue masivo de Gaseras';

    pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
            p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
            ,p_ntraza_in          => 1995
            ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            ,p_usuario_in         => p_usuario_in
            ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
          );
END pr_valida_cargue_masivo;

PROCEDURE pr_gu_cargue_vida(
  p_id_cargue_in              IN  msv_tb_cargue_masivo.id%TYPE
  ,p_fila_registrar_in        IN   cu_info_cargue%ROWTYPE
  ,p_info_cargue_in           IN   pac_msv_utilidades.t_array
  ,p_usuario_in               IN   msv_tb_cargue_masivo.usuario_creacion%TYPE
  ,p_indicador_proceso_out    OUT  VARCHAR2)
IS
/**************************************************************************
    NOMBRE:         pr_gu_cargue_vida
    TIPO:           Procedimiento
    PROPOSITO:      Procedimiento encargado de procesar el cargue masivo
                    Gaseras
    CREADO POR:     Company


    PARAMETROS DE ENTRADA:
    Nombre                      Tipo            Descripcion
    -------------------         --------        -----------------------
    p_id_cargue_in              NUMBER          Identificador de la tabla msv_tb_cargue_masivo,
                                                correspondiente al id del cargue
    p_tipo_cargue_in            VARCHAR2        Codigo parametrizado del tipo de Gasera cargado
                                                Vida, Exequial, Doble Cupon
    p_usuario_in                VARCHAR2        Usuario que ejecuta el proceso

    PARAMETROS DE SALIDA:
    Nombre                      Tipo        Descripcion
    ---------                   --------    -----------------------------------
    p_indicador_proceso_out     VARCHAR     Indicador resultado del proceso
    p_observacion_proceso_out   VARCHAR     Texto con el restultado del proceso

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         30/11/2017  Company                 Creacion y documentacion de funcion

***************************************************************************/
  ----------------------------------------------------------------------------
  --  SECCION CONSTANTES
  ----------------------------------------------------------------------------
  c_nombre_procedimiento      VARCHAR2(30) DEFAULT 'pr_gu_cargue_vida';

  -----------------------------------------------------------------------------
  -- SECCION VARCHAR
  -----------------------------------------------------------------------------
  v_tipo_documento_iaxis      VARCHAR2(10);

  -----------------------------------------------------------------------------
  -- SECCION NUMBER
  -----------------------------------------------------------------------------
  n_inicio_beneficiario    CONSTANT NUMBER DEFAULT 20;
  n_fin_beneficiario       CONSTANT NUMBER DEFAULT 70;
 -- n_id_vida_detalle        GSE_TB_VIDA_DETALLE.id%TYPE;
  n_indice                 NUMBER DEFAULT 20;
  n_total_benef            NUMBER DEFAULT 1;
  -----------------------------------------------------------------------------
  -- SECCION CURSORES
  -----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION %TYPE
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION %ROWTYPE
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION PROCEDIMIENTOS/FUNCIONES PRIVADAS
  ----------------------------------------------------------------------------

BEGIN
  --Se obtiene el consecutivo del detalle
 -- n_id_vida_detalle := gse_sc_vida_detalle.NEXTVAL;

  --Se consulta la homologacion del tipo de documento con iaxis
  v_tipo_documento_iaxis := fu_homologa_tipo_doc(p_info_cargue_in(1));


   --Se recorren los beneficiarios por campos y se registran
   <<leer_beneficiario>>
   BEGIN
       WHILE n_indice < n_fin_beneficiario
       LOOP

          --Valida que el campo <NOMBRE>, no este vacio para registrar el beneficiario
          IF p_info_cargue_in(n_indice) IS NOT NULL THEN
          --

              n_total_benef := n_total_benef +1;
          --
          END IF;

          n_indice := n_indice + 5;
       END LOOP;
   EXCEPTION
   WHEN OTHERS THEN
      p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;

      pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
          p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
          ,p_ntraza_in          => 2162
          ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
          ,p_usuario_in         => p_usuario_in
          ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
        );
   END leer_beneficiario;

   --Se inicializa el valor del indice en 70, para tomar desde ese campo el dependiente
   n_indice := n_fin_beneficiario;

   --Valida que los campos obligatorios no esten vacios para registrar el dependiente
   IF p_info_cargue_in(n_indice) IS NOT NULL
     AND p_info_cargue_in(n_indice+6) IS NOT NULL  THEN
   --

     --Se consulta la homologacion del tipo de documento con iaxis
     v_tipo_documento_iaxis := fu_homologa_tipo_doc(p_info_cargue_in(n_indice+1));

     SELECT
       DECODE(v_tipo_documento_iaxis,NULL,p_info_cargue_in(n_indice+1),v_tipo_documento_iaxis)
       INTO v_tipo_documento_iaxis
     FROM DUAL;

    END IF;
--
 EXCEPTION
 WHEN OTHERS THEN
    p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;

    pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
        p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
        ,p_ntraza_in          => 2210
        ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        ,p_usuario_in         => p_usuario_in
        ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
      );
END pr_gu_cargue_vida;
-- INICIO PYALLTIT
PROCEDURE pr_gu_por_tipo_cargue_as(
  p_id_cargue_in              IN   msv_tb_cargue_masivo.id%TYPE
  ,p_tipo_cargue_in           IN   msv_tb_cargue_masivo.tipo%TYPE
  ,p_fila_registrar_in        IN   cu_info_cargue%ROWTYPE
  ,p_info_cargue_in           IN   pac_msv_utilidades.t_array
  ,p_usuario_in               IN   msv_tb_cargue_masivo.usuario_creacion%TYPE
  ,p_indicador_proceso_out    OUT  VARCHAR2)
IS
/**************************************************************************
    NOMBRE:         pr_gu_por_tipo_cargue
    TIPO:           Procedimiento
    PROPOSITO:      Procedimiento encargado de procesar el cargue masivo
    CREADO POR:     Company


    PARAMETROS DE ENTRADA:
    Nombre                      Tipo            Descripcion
    -------------------         --------        -----------------------
    p_id_cargue_in              NUMBER          Identificador de la tabla msv_tb_cargue_masivo,
                                                correspondiente al id del cargue
    p_tipo_cargue_in            VARCHAR2        Codigo parametrizado del tipo de Cargue
    p_usuario_in                VARCHAR2        Usuario que ejecuta el proceso

    PARAMETROS DE SALIDA:
    Nombre                      Tipo        Descripcion
    ---------                   --------    -----------------------------------
    p_indicador_proceso_out     VARCHAR     Indicador resultado del proceso
    p_observacion_proceso_out   VARCHAR     Texto con el restultado del proceso

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         13/03/2018  Company                 Creacion y documentacion de funcion

***************************************************************************/
  ----------------------------------------------------------------------------
  --  SECCION CONSTANTES
  ----------------------------------------------------------------------------
  c_nombre_procedimiento      VARCHAR2(30) DEFAULT 'pr_gu_por_tipo_cargue';

  -----------------------------------------------------------------------------
  -- SECCION VARCHAR
  -----------------------------------------------------------------------------
  v_tipo_documento_iaxis      VARCHAR2(10);
  nContar NUMBER := 0;
  -----------------------------------------------------------------------------
  -- SECCION NUMBER
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION CURSORES
  -----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION %TYPE
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION %ROWTYPE
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION PROCEDIMIENTOS/FUNCIONES PRIVADAS
  ----------------------------------------------------------------------------
   n_test number;
BEGIN

  p_indicador_proceso_out   := pac_msv_constantes.c_respuesta_exitosa;

  --Se evalua el tipo de cargue
  CASE p_tipo_cargue_in
    ---------------------------------------------------
    --   CARGUE VENTAS DIARIAS
    ---------------------------------------------------
    WHEN pac_msv_constantes.c_tipo_cargue_ventas_diarias THEN
    <<registra_vtas_diarias>>
    BEGIN
        --Se consulta la homologacion del tipo de documento con iaxis
        v_tipo_documento_iaxis := fu_homologa_tipo_doc(p_info_cargue_in(2));

    EXCEPTION
    WHEN OTHERS THEN
       p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
       pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
            p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
            ,p_ntraza_in          => 2339
            ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            ,p_usuario_in         => p_usuario_in
            ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
          );
    END registra_vtas_diarias;
    ---------------------------------------------------
    --   CARGUE FACTURACION
    ---------------------------------------------------
    WHEN pac_msv_constantes.c_tipo_cargue_facturacion THEN
    <<registra_facturacion>>
    BEGIN
        --Se consulta la homologacion del tipo de documento con iaxis
        v_tipo_documento_iaxis := fu_homologa_tipo_doc(p_info_cargue_in(3));


    EXCEPTION
    WHEN OTHERS THEN
       p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
       pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
            p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
            ,p_ntraza_in          => 2339
            ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            ,p_usuario_in         => p_usuario_in
            ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
          );
    END registra_facturacion;
    ---------------------------------------------------
    --   CARGUE NOVEDADES
    ---------------------------------------------------
    WHEN pac_msv_constantes.c_tipo_cargue_novedades THEN
    <<registra_novedades>>
    BEGIN


NULL;
    EXCEPTION
    WHEN OTHERS THEN
       p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
       pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
            p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
            ,p_ntraza_in          => 2339
            ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            ,p_usuario_in         => p_usuario_in
            ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
          );
    END registra_novedades;
    ---------------------------------------------------
    --   CARGUE RENOVACIONES
    ---------------------------------------------------
    WHEN pac_msv_constantes.c_tipo_cargue_renovaciones THEN
    <<registra_renovaciones>>
    BEGIN

NULL;
    EXCEPTION
    WHEN OTHERS THEN
       p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
       pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
            p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
            ,p_ntraza_in          => 2339
            ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            ,p_usuario_in         => p_usuario_in
            ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
          );
    END registra_renovaciones;
    ---------------------------------------------------
    --   CARGUE CANCELACIONES
    ---------------------------------------------------
    WHEN pac_msv_constantes.c_tipo_cargue_cancelaciones THEN
    <<registra_cancelaciones>>
    BEGIN

         NULL;

    EXCEPTION
    WHEN OTHERS THEN
       p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
       pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
            p_nombre_objeto_in   =>  c_nombre_paquete||'.'||c_nombre_procedimiento
            ,p_ntraza_in          => 2339
            ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            ,p_usuario_in         => p_usuario_in
            ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
          );
    END registra_cancelaciones;
    ---------------------------------------------------
    --   CARGUE DEVOLUCIONES
    ---------------------------------------------------
    WHEN pac_msv_constantes.c_tipo_cargue_devoluciones THEN
    <<registra_devoluciones>>
    BEGIN

         NULL;

    EXCEPTION
    WHEN OTHERS THEN

       p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
       pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
            p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
            ,p_ntraza_in          => 2340
            ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            ,p_usuario_in         => p_usuario_in
            ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
          );
    END registra_devoluciones;

    ---- inicio pyalltit
        WHEN 'AS' THEN -- pac_msv_constantes.c_tipo_cargue_asegurados THEN
    <<registra_asegurados>>
    nContar := NVL(nContar,0) + 1;

    BEGIN 
--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB
      INSERT INTO int_carga_generico
       (PROCESO,NLINEA,NCARGA,TIPO_OPER,TIPOREGISTRO,CAMPO01,
        CAMPO02, CAMPO03,CAMPO04,CAMPO05,CAMPO06,CAMPO07, CAMPO08, CAMPO09,
        --Ini Company(LARO) 28112020 Factura Electronica
        --CAMPO10,CAMPO11,CAMPO12, CAMPO13,CAMPO14,CAMPO15,CAMPO16,CAMPO17,CAMPO18 ) 
        CAMPO10,CAMPO11,CAMPO12, CAMPO13,CAMPO14,CAMPO15,CAMPO16,CAMPO17,CAMPO18,CAMPO19,CAMPO20,CAMPO21,CAMPO22,CAMPO23 ) 
        --Fin Company(LARO) 28112020 Factura Electronica
       values(
       p_id_cargue_in, -- PROCESO
       nContar, -- 1, -- NLINEA
       p_id_cargue_in, -- NCARGA
       'AS', -- TIPO_OPER
       '1', -- TIPOREGISTRO
       p_info_cargue_in(0),-- POLIZA   -- CAMPO01
       p_info_cargue_in(1),-- Primer Nombre -- CAMPO02
       p_info_cargue_in(2),--Segundo Nombre  -- CAMPO03
       p_info_cargue_in(3),--Primer Apellido -- CAMPO04
       p_info_cargue_in(4),-- Segundo Apellido -- CAMPO05
       p_info_cargue_in(5), --Tipo de Documento de Identificacion  -- CAMPO06   
       p_info_cargue_in(6),-- Numero de Identificacion      -- CAMPO07 
       p_info_cargue_in(7), -- Genero -- CAMPO08
       p_info_cargue_in(8), --Fecha Nacimiento -- CAMPO09
       p_info_cargue_in(9), -- Fecha de efecto de la Novedad -- Fecha de ingreso a la poliza secambio -- CAMPO10
       p_info_cargue_in(10), --Plan -- CAMPO11
       p_info_cargue_in(11), -- Codigo    -- CAMPO12
       p_info_cargue_in(12),--Curso o Sede  -- CAMPO13
       p_info_cargue_in(13), -- Correo electronico del Asegurado --  CAMPO14
       DECODE(p_info_cargue_in(14),'EX',4,NULL), -- Causa anulacion -- CAMPO15
       p_info_cargue_in(14), -- Tipo de Novedad       -- CAMPO16
       p_info_cargue_in(15), --DECODE(p_info_cargue_in(14),'IN',0,p_info_cargue_in(15)), -- DECODE(p_info_cargue_in(14),'EX',p_info_cargue_in(16),NULL) -- p_info_cargue_in(15) --  mtvo anulacion     -- CAMPO17
       --Ini Company(LARO) 28112020 Factura Electronica
       --DECODE(p_info_cargue_in(14),'IN',0,p_info_cargue_in(15))
       DECODE(p_info_cargue_in(14),'IN',0,p_info_cargue_in(15)),
       p_info_cargue_in(17),    --Direccion
       p_info_cargue_in(18),    --Departamento
       p_info_cargue_in(19),    --Ciudad 
       p_info_cargue_in(20),    --Telefono Fijo 
       p_info_cargue_in(21)     --telefono Movil 
       --Fin Company(LARO) 28112020 Factura Electronica
     );
--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB     
    EXCEPTION
    WHEN OTHERS THEN
       p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_gu_por_tipo_cargue_as 2880 EXCEPCION AL INSERTAR EN INT_CARGA_GENERICO', 1, '' , SQLERRM);
       p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
       pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
            p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
            ,p_ntraza_in          => 2340
            ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            ,p_usuario_in         => p_usuario_in
            ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
          );
    END registra_asegurados;
    --- fin pyalltit
  END CASE;

--
 EXCEPTION
 WHEN OTHERS THEN
    p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;

    pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
        p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
        ,p_ntraza_in          => 1306
        ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        ,p_usuario_in         => p_usuario_in
        ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
      );
END pr_gu_por_tipo_cargue_as;
-- FIN PYALLTIT
PROCEDURE pr_gu_por_tipo_cargue(
  p_id_cargue_in              IN   msv_tb_cargue_masivo.id%TYPE
  ,p_tipo_cargue_in           IN   msv_tb_cargue_masivo.tipo%TYPE
  ,p_fila_registrar_in        IN   cu_info_cargue%ROWTYPE
  ,p_info_cargue_in           IN   pac_msv_utilidades.t_array
  ,p_usuario_in               IN   msv_tb_cargue_masivo.usuario_creacion%TYPE
  ,p_indicador_proceso_out    OUT  VARCHAR2)
IS
/**************************************************************************
    NOMBRE:         pr_gu_por_tipo_cargue
    TIPO:           Procedimiento
    PROPOSITO:      Procedimiento encargado de procesar el cargue masivo
    CREADO POR:     Company


    PARAMETROS DE ENTRADA:
    Nombre                      Tipo            Descripcion
    -------------------         --------        -----------------------
    p_id_cargue_in              NUMBER          Identificador de la tabla msv_tb_cargue_masivo,
                                                correspondiente al id del cargue
    p_tipo_cargue_in            VARCHAR2        Codigo parametrizado del tipo de Cargue
    p_usuario_in                VARCHAR2        Usuario que ejecuta el proceso

    PARAMETROS DE SALIDA:
    Nombre                      Tipo        Descripcion
    ---------                   --------    -----------------------------------
    p_indicador_proceso_out     VARCHAR     Indicador resultado del proceso
    p_observacion_proceso_out   VARCHAR     Texto con el restultado del proceso

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         13/03/2018  Company                 Creacion y documentacion de funcion

***************************************************************************/
  ----------------------------------------------------------------------------
  --  SECCION CONSTANTES
  ----------------------------------------------------------------------------
  c_nombre_procedimiento      VARCHAR2(30) DEFAULT 'pr_gu_por_tipo_cargue';

  -----------------------------------------------------------------------------
  -- SECCION VARCHAR
  -----------------------------------------------------------------------------
  v_tipo_documento_iaxis      VARCHAR2(10);

  -----------------------------------------------------------------------------
  -- SECCION NUMBER
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION CURSORES
  -----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION %TYPE
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION %ROWTYPE
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION PROCEDIMIENTOS/FUNCIONES PRIVADAS
  ----------------------------------------------------------------------------
   n_test number;
BEGIN
  p_indicador_proceso_out   := pac_msv_constantes.c_respuesta_exitosa;

  --Se evalua el tipo de cargue
  CASE p_tipo_cargue_in
    ---------------------------------------------------
    --   CARGUE VENTAS DIARIAS
    ---------------------------------------------------
    WHEN pac_msv_constantes.c_tipo_cargue_ventas_diarias THEN
    <<registra_vtas_diarias>>
    BEGIN
        --Se consulta la homologacion del tipo de documento con iaxis
        v_tipo_documento_iaxis := fu_homologa_tipo_doc(p_info_cargue_in(2));


    EXCEPTION
    WHEN OTHERS THEN
       p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
       pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
            p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
            ,p_ntraza_in          => 2339
            ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            ,p_usuario_in         => p_usuario_in
            ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
          );
    END registra_vtas_diarias;
    ---------------------------------------------------
    --   CARGUE FACTURACION
    ---------------------------------------------------
    WHEN pac_msv_constantes.c_tipo_cargue_facturacion THEN
    <<registra_facturacion>>
    BEGIN
        --Se consulta la homologacion del tipo de documento con iaxis
        v_tipo_documento_iaxis := fu_homologa_tipo_doc(p_info_cargue_in(3));


    EXCEPTION
    WHEN OTHERS THEN
       p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
       pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
            p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
            ,p_ntraza_in          => 2339
            ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            ,p_usuario_in         => p_usuario_in
            ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
          );
    END registra_facturacion;
    ---------------------------------------------------
    --   CARGUE NOVEDADES
    ---------------------------------------------------
    WHEN pac_msv_constantes.c_tipo_cargue_novedades THEN
    <<registra_novedades>>
    BEGIN


NULL;
    EXCEPTION
    WHEN OTHERS THEN
       p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
       pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
            p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
            ,p_ntraza_in          => 2339
            ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            ,p_usuario_in         => p_usuario_in
            ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
          );
    END registra_novedades;
    ---------------------------------------------------
    --   CARGUE RENOVACIONES
    ---------------------------------------------------
    WHEN pac_msv_constantes.c_tipo_cargue_renovaciones THEN
    <<registra_renovaciones>>
    BEGIN

NULL;
    EXCEPTION
    WHEN OTHERS THEN
       p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
       pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
            p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
            ,p_ntraza_in          => 2339
            ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            ,p_usuario_in         => p_usuario_in
            ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
          );
    END registra_renovaciones;
    ---------------------------------------------------
    --   CARGUE CANCELACIONES
    ---------------------------------------------------
    WHEN pac_msv_constantes.c_tipo_cargue_cancelaciones THEN
    <<registra_cancelaciones>>
    BEGIN

         NULL;

    EXCEPTION
    WHEN OTHERS THEN
       p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
       pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
            p_nombre_objeto_in   =>  c_nombre_paquete||'.'||c_nombre_procedimiento
            ,p_ntraza_in          => 2339
            ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            ,p_usuario_in         => p_usuario_in
            ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
          );
    END registra_cancelaciones;
    ---------------------------------------------------
    --   CARGUE DEVOLUCIONES
    ---------------------------------------------------
    WHEN pac_msv_constantes.c_tipo_cargue_devoluciones THEN
    <<registra_devoluciones>>
    BEGIN

         NULL;

    EXCEPTION
    WHEN OTHERS THEN

       p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
       pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
            p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
            ,p_ntraza_in          => 2340
            ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            ,p_usuario_in         => p_usuario_in
            ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
          );
    END registra_devoluciones;
  END CASE;

--
 EXCEPTION
 WHEN OTHERS THEN
    p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;

    pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
        p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
        ,p_ntraza_in          => 1306
        ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        ,p_usuario_in         => p_usuario_in
        ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
      );
END pr_gu_por_tipo_cargue;

PROCEDURE pr_gu_historico(
   p_info_cargue_in           IN   cu_info_cargue%ROWTYPE
  ,p_usuario_in               IN   msv_tb_cargue_masivo.usuario_creacion%TYPE)
IS
/**************************************************************************
    NOMBRE:         pr_gu_historico
    TIPO:           Procedimiento
    PROPOSITO:      Procedimiento encargado de registrar cada registro del cargue
                    en el historico respectivo
    CREADO POR:     Company


    PARAMETROS DE ENTRADA:
    Nombre                      Tipo            Descripcion
    -------------------         --------        -----------------------
    p_id_cargue_in              NUMBER          Identificador de la tabla msv_tb_cargue_masivo,
                                                correspondiente al id del cargue
    p_tipo_cargue_in            VARCHAR2        Codigo parametrizado del tipo de cargue
    p_usuario_in                VARCHAR2        Usuario que ejecuta el proceso

    PARAMETROS DE SALIDA:
    Nombre                      Tipo        Descripcion
    ---------                   --------    -----------------------------------
    p_indicador_proceso_out     VARCHAR     Indicador resultado del proceso
    p_observacion_proceso_out   VARCHAR     Texto con el restultado del proceso

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         13/03/2018  Company                 Creacion y documentacion de funcion

***************************************************************************/
  ----------------------------------------------------------------------------
  --  SECCION CONSTANTES
  ----------------------------------------------------------------------------
  c_nombre_procedimiento      VARCHAR2(30) DEFAULT 'pr_gu_historico';

  -----------------------------------------------------------------------------
  -- SECCION VARCHAR
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION NUMBER
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- SECCION CURSORES
  -----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION %TYPE
  ----------------------------------------------------------------------------


  ----------------------------------------------------------------------------
  -- SECCION %ROWTYPE
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- SECCION PROCEDIMIENTOS/FUNCIONES PRIVADAS
  ----------------------------------------------------------------------------

BEGIN
     INSERT INTO msv_tb_hist_cargue_masivo_det
     (ID                             ,ID_CARGUE               --1
      ,NRO_LINEA                     ,TEXTO                   --2
      ,ESTADO                        ,OBSERVACIONES           --3
      ,USUARIO_CREACION              ,FECHA_CREACION          --4
      ,USUARIO_MODIFICACION          ,FECHA_MODIFICACION      --5
      ) VALUES (
      msv_sc_hist_cargue_masivo_det.NEXTVAL     ,p_info_cargue_in.id_cargue  --1
      ,p_info_cargue_in.nro_linea               ,p_info_cargue_in.texto      --2
      ,p_info_cargue_in.estado                  ,p_info_cargue_in.observaciones        --3
      ,p_info_cargue_in.usuario_creacion        ,p_info_cargue_in.fecha_creacion       --4
      ,p_info_cargue_in.usuario_modificacion    ,p_info_cargue_in.fecha_modificacion   --5
      );
--
 EXCEPTION
 WHEN OTHERS THEN
    pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
        p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
        ,p_ntraza_in          => 2543
        ,p_mensaje_in         => SQLCODE || ' @ ' ||SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        ,p_usuario_in         => p_usuario_in
        ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
      );
END pr_gu_historico;

  ----------------------------------------------------------------------------
  --  SECCION PROCEDIMIENTOS PUBLICOS
  ----------------------------------------------------------------------------

PROCEDURE pr_procesa_cargue_masivo(
  p_id_cargue_in              IN  msv_tb_cargue_masivo.id%TYPE
  ,p_tipo_cargue_in           IN  msv_tb_cargue_masivo.tipo%TYPE
  ,p_usuario_in               IN   msv_tb_cargue_masivo.usuario_creacion%TYPE
  ,p_indicador_proceso_out    OUT  VARCHAR2
  ,p_observacion_proceso_out  OUT  VARCHAR2)
IS
/**************************************************************************
    NOMBRE:         pr_procesa_cargue_masivo
    TIPO:           Procedimiento
    PROPOSITO:      Procedimiento encargado de procesar el cargue masivo
    CREADO POR:     Company


    PARAMETROS DE ENTRADA:
    Nombre                      Tipo            Descripcion
    -------------------         --------        -----------------------
    p_id_cargue_in              NUMBER          Identificador de la tabla msv_tb_cargue_masivo,
                                                correspondiente al id del cargue
    p_tipo_cargue_in            VARCHAR2        Codigo parametrizado del tipo de cargue
    p_usuario_in                VARCHAR2        Usuario que ejecuta el proceso

    PARAMETROS DE SALIDA:
    Nombre                      Tipo        Descripcion
    ---------                   --------    -----------------------------------
    p_indicador_proceso_out     VARCHAR     Indicador resultado del proceso
    p_observacion_proceso_out   VARCHAR     Texto con el restultado del proceso

    REVISIONES:
    Version     Fecha       Autor                   Descripcion
    ---------   ----------  --------------------    -----------------------
    1.0         13/03/2018  Company                 Creacion y documentacion de funcion

***************************************************************************/
  ----------------------------------------------------------------------------
  --  SECCION CONSTANTES
  ----------------------------------------------------------------------------
  c_long_columna_vtas_diarias     CONSTANT msv_tb_parametro.codigo%TYPE DEFAULT 'LONG_COL_TB_VENTAS';
  c_long_columna_facturacion      CONSTANT msv_tb_parametro.codigo%TYPE DEFAULT 'LONG_COL_TB_FACTURAC';
  c_long_columna_novedades        CONSTANT msv_tb_parametro.codigo%TYPE DEFAULT 'LONG_COL_TB_NOVEDADE';
  c_long_columna_renovacion       CONSTANT msv_tb_parametro.codigo%TYPE DEFAULT 'LONG_COL_TB_RENOVA';
  c_long_columna_cancela          CONSTANT msv_tb_parametro.codigo%TYPE DEFAULT 'LONG_COL_TB_CANCELA';
  c_long_encabezado_vtas_diarias  CONSTANT msv_tb_parametro.codigo%TYPE DEFAULT 'LONG_COL_EN_VENTAS';
  c_long_encabezado_facturacion   CONSTANT msv_tb_parametro.codigo%TYPE DEFAULT 'LONG_COL_EN_FACTURAC';
  c_long_encabezado_novedades     CONSTANT msv_tb_parametro.codigo%TYPE DEFAULT 'LONG_COL_EN_NOVEDA';
  c_long_encabezado_renovacion    CONSTANT msv_tb_parametro.codigo%TYPE DEFAULT 'LONG_COL_EN_RENOVA';
  c_long_encabezado_cancelacion   CONSTANT msv_tb_parametro.codigo%TYPE DEFAULT 'LONG_COL_EN_CANCELA';
  c_long_columna_novedades_720    CONSTANT msv_tb_parametro.codigo%TYPE DEFAULT 'LONG_COL_TB_NOVD_720';
  c_long_encabezado_novedad_720   CONSTANT msv_tb_parametro.codigo%TYPE DEFAULT 'LONG_COL_EN_NOVD_720';
  c_long_columna_cancel_720       CONSTANT msv_tb_parametro.codigo%TYPE DEFAULT 'LONG_COL_TB_CANC_720';
  c_long_encabezado_cancel_720    CONSTANT msv_tb_parametro.codigo%TYPE DEFAULT 'LONG_COL_EN_CANC_720';
  c_nombre_procedimiento          VARCHAR2(30) DEFAULT 'pr_procesa_cargue_masivo';
  -----------------------------------------------------------------------------
  -- SECCION VARCHAR
  -----------------------------------------------------------------------------
  v_parametros              VARCHAR2(2000) := 'Parametros (p_id_cargue_in => '||p_id_cargue_in||','||
                                              'p_tipo_cargue_in => '||p_tipo_cargue_in||','||
                                              'p_usuario_in => '||p_usuario_in||') ';
  v_sql_cargue_masivo         VARCHAR2(40) DEFAULT 'truncate table msv_tb_cargue_masivo_det';
  v_estado_cargue             msv_tb_cargue_masivo_det.estado%TYPE;
  v_error_x_estructura        VARCHAR2(1) DEFAULT c_n;
  v_parametro                 msv_tb_parametro.valor%TYPE;
  v_parametro_enc             msv_tb_parametro.valor%TYPE;
  v_long_columnas             msv_tb_parametro.codigo%TYPE;
  v_long_columnas_enc         msv_tb_parametro.codigo%TYPE;
  v_valida_encabezados        msv_tb_parametro.codigo%TYPE;
  v_valida_detalles           msv_tb_parametro.codigo%TYPE;
  -----------------------------------------------------------------------------
  -- SECCION NUMBER
  -----------------------------------------------------------------------------
  --Contiene el valor limite para el procesamiento de registros del cargue
  n_limite            CONSTANT NUMBER DEFAULT  1000;
  n_total_gestionado  NUMBER DEFAULT   0;
  n_total_pendiente   NUMBER DEFAULT   0;
  n_total_cargue      NUMBER DEFAULT   0;
  n_total_exitoso     NUMBER DEFAULT   0;
  n_total_fallido     NUMBER DEFAULT   0;
  n_cant_registros    NUMBER DEFAULT   0;
  n_tipo_poliza       NUMBER; --51746 14/08/2019
  -----------------------------------------------------------------------------
  -- SECCION BOOLEAN
  -----------------------------------------------------------------------------
  --Contiene el valor limite para el procesamiento de registros del cargue
  b_validacion_encabezado  BOOLEAN DEFAULT FALSE;
  -----------------------------------------------------------------------------
  -- SECCION CURSORES
  -----------------------------------------------------------------------------
  CURSOR cu_contar_cargue
  IS
    select
     NVL(SUM(
       CASE WHEN md.estado = pac_msv_constantes.c_estado_cargue_exitoso THEN 1 ELSE 0
       END),0) AS total_exitoso
     ,NVL(SUM(
       CASE WHEN md.estado = pac_msv_constantes.c_estado_cargue_inconsistente THEN 1 ELSE 0
       END),0) AS total_fallido
    from msv_tb_cargue_masivo_det md
    where id_cargue = p_id_cargue_in;
  --
  CURSOR cu_encontrar_sproduc(p_id_cargue_in IN msv_tb_cargue_masivo.id%TYPE)
  IS
  	select sproduc
  	from  msv_tb_cargue_masivo mtcm
  	where mtcm.id=p_id_cargue_in;
  ----------------------------------------------------------------------------
  -- SECCION %TYPE
  ----------------------------------------------------------------------------
  t_tmp_cargue        TYP_T_CARGUE_MASIVO;
  t_tmp_array         pac_msv_utilidades.t_array;
  ----------------------------------------------------------------------------
  -- SECCION %ROWTYPE
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  -- SECCION %EXCEPTIONS
  ----------------------------------------------------------------------------
    EXCEPTION_PRODUCTO EXCEPTION;
   ----------------------------------------------------------------------------
   -- SECCION PROCEDIMIENTOS/FUNCIONES PRIVADAS
   ----------------------------------------------------------------------------
BEGIN

  OPEN cu_encontrar_sproduc(p_id_cargue_in);
  FETCH cu_encontrar_sproduc into n_sproduc;
  close cu_encontrar_sproduc;
  IF n_sproduc IS null THEN
     RAISE EXCEPTION_PRODUCTO;
  END IF;

        ---------------------------------------------------
        --   CARGUE VENTAS DIARIAS 411 o 720
        ---------------------------------------------------
  IF    p_tipo_cargue_in = pac_msv_constantes.c_tipo_cargue_ventas_diarias THEN
        v_long_columnas      := c_long_columna_vtas_diarias;
        v_long_columnas_enc  := c_long_encabezado_vtas_diarias;
        v_valida_encabezados := c_s;
        v_valida_detalles    := c_s;
        ---------------------------------------------------
        --   CARGUE FACTURACION 411 0 720
        ---------------------------------------------------
  ELSIF p_tipo_cargue_in = pac_msv_constantes.c_tipo_cargue_facturacion THEN
        v_long_columnas_enc  := c_long_encabezado_facturacion;
        v_long_columnas      := c_long_columna_facturacion;
        v_valida_encabezados := c_s;
        v_valida_detalles    := c_s;
        ---------------------------------------------------
        --   CARGUE RENOVACIONES 411
        ---------------------------------------------------
  ELSIF p_tipo_cargue_in = pac_msv_constantes.c_tipo_cargue_renovaciones THEN
        v_long_columnas_enc  := c_long_encabezado_renovacion;
        v_long_columnas      := c_long_columna_renovacion;
        v_valida_encabezados := c_s;
        v_valida_detalles    := c_s;
        ---------------------------------------------------
        --   CARGUE NOVEDADES 411
        ---------------------------------------------------
  ELSIF p_tipo_cargue_in = pac_msv_constantes.c_tipo_cargue_novedades
        AND pac_msv_constantes.c_cod_prod_hogar_masivos = n_sproduc THEN
        v_long_columnas_enc  := c_long_encabezado_novedades;
        v_long_columnas      := c_long_columna_novedades;
        v_valida_encabezados := c_s;
        v_valida_detalles    := c_s;
        ---------------------------------------------------
        --   CARGUE CANCELACIONES 411
        ---------------------------------------------------
  ELSIF p_tipo_cargue_in = pac_msv_constantes.c_tipo_cargue_cancelaciones
        AND pac_msv_constantes.c_cod_prod_hogar_masivos = n_sproduc THEN
        v_long_columnas_enc  := c_long_encabezado_cancelacion;
        v_long_columnas      := c_long_columna_cancela;
        v_valida_encabezados := c_s;
        v_valida_detalles    := c_s;
        ---------------------------------------------------
        --   CARGUE DEVOLUCIONES 411
        ---------------------------------------------------
  ELSIF p_tipo_cargue_in = pac_msv_constantes.c_tipo_cargue_devoluciones
        AND pac_msv_constantes.c_cod_prod_hogar_masivos = n_sproduc  THEN
        --v_long_columnas_enc -- no aplica para este tipo de cargue
        --v_long_columnas     -- no aplica para este tipo de cargue
        v_valida_encabezados := c_n;
        v_valida_detalles    := c_n;
        b_validacion_encabezado := TRUE;
        --------------------------------------------------
        --   CARGUE NOVEDADES 720
        ---------------------------------------------------
  ELSIF p_tipo_cargue_in= pac_msv_constantes.c_tipo_cargue_novedades
        AND pac_msv_constantes.c_cod_prod_incendio_colectivo = n_sproduc THEN
        v_long_columnas_enc  := c_long_encabezado_novedad_720;
        v_long_columnas      := c_long_columna_novedades_720;
        v_valida_encabezados := c_s;
        v_valida_detalles    := c_s;
         ---------------------------------------------------
        --   CARGUE CANCELACIONES 720
        ---------------------------------------------------
  ELSIF p_tipo_cargue_in =  pac_msv_constantes.c_tipo_cargue_cancelaciones
        AND pac_msv_constantes.c_cod_prod_incendio_colectivo =n_sproduc THEN
        v_long_columnas_enc  := c_long_encabezado_cancel_720;
        v_long_columnas      := c_long_columna_cancel_720;
        v_valida_encabezados := c_s;
        v_valida_detalles    := c_s;
         ---------------------------------------------------
        --   CARGUE DEVOLUCIONES 720
        ---------------------------------------------------
  ELSIF p_tipo_cargue_in = pac_msv_constantes.c_tipo_cargue_devoluciones
        AND pac_msv_constantes.c_cod_prod_incendio_colectivo = n_sproduc  THEN
        --v_long_columnas_enc -- no aplica para este tipo de cargue
        --v_long_columnas     -- no aplica para este tipo de cargue
        v_valida_encabezados := c_n;
        v_valida_detalles    := c_n;
        b_validacion_encabezado := TRUE;
  -- INICIO PYALLTIT      
  ELSIF p_tipo_cargue_in = 'AS'  THEN   
        v_valida_encabezados := c_n;
        v_valida_detalles    := c_n;
        b_validacion_encabezado := TRUE;
  -- FIN PYALLTIT  
  END IF;
	v_parametro := pac_msv_utilidades.fu_valor_parametro(
				  v_long_columnas
				  ,c_grupo_cargue_masivo);
  <<inicializar>>
  BEGIN
    IF cu_info_cargue%ISOPEN THEN
          CLOSE cu_info_cargue;
    END IF;
  END inicializar;

  IF v_error_x_estructura = c_s THEN
  --
       p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;

       p_observacion_proceso_out := pac_msv_utilidades.fu_valor_parametro
        (
          c_cod_error_general_no_cargo
          ,c_grupo_error_gasera
        );
      delete msv_tb_cargue_masivo where id = p_id_cargue_in;
  --
  ELSE
  --
      <<inicializar>>
      BEGIN
        IF cu_info_cargue%ISOPEN THEN
              CLOSE cu_info_cargue;
        END IF;
      END inicializar;
      --SAVEPOINT procesar_detalle;
      p_indicador_proceso_out   := pac_msv_constantes.c_respuesta_exitosa;
      n_total_cargue := 0;
      n_total_exitoso:= 0;
      n_total_fallido:= 0;

      <<registrar_detalle>>
      BEGIN
      --

        OPEN cu_info_cargue(p_id_cargue_in);
        LOOP
        --

           --*********************************************************
           --Se realiza el procesamiento cada n registros
           --**********************************************************
           FETCH cu_info_cargue BULK COLLECT INTO  t_tmp_cargue LIMIT n_limite;
           EXIT WHEN t_tmp_cargue.COUNT = 0;
           -- Se recorren los registros para validarlos

           FOR idx IN 1 .. t_tmp_cargue.COUNT
           LOOP

             -- Indentifica el registro tipo encabezado
             IF (idx = 0 AND n_total_cargue = 0) THEN
                IF v_valida_encabezados = c_s THEN

                  v_parametro_enc := pac_msv_utilidades.fu_valor_parametro(v_long_columnas_enc,c_grupo_cargue_masivo);
                  t_tmp_array := pac_msv_utilidades.fu_obtener_delim(t_tmp_cargue(idx).texto, v_parametro_enc,pac_msv_constantes.c_caracter_coma);
                  pr_valida_encabezado(p_tipo_cargue_in,
                                       t_tmp_array,
                                       n_cant_registros,
                                       p_usuario_in,
                                       v_indicador_proceso,
                                       v_observacion_proceso);

                  IF v_indicador_proceso = pac_msv_constantes.c_respuesta_exitosa THEN
                     b_validacion_encabezado := TRUE;
                     -- Registro del encabezado en la tabla de cargue encabezado
                     pr_gu_encabezado(p_id_cargue_in, t_tmp_array ,p_usuario_in, v_indicador_proceso,v_observacion_proceso);

                     IF v_indicador_proceso = pac_msv_constantes.c_respuesta_exitosa THEN
                        t_tmp_cargue(idx).estado := pac_msv_constantes.c_estado_cargue_exitoso;
                     ELSE
                        t_tmp_cargue(idx).observaciones := v_observacion_proceso;
                        t_tmp_cargue(idx).estado := pac_msv_constantes.c_estado_cargue_inconsistente;
                     END IF;

                     --Registro en el historico del cargue
                     pr_gu_historico(t_tmp_cargue(idx) ,p_usuario_in);
                     -- CONFIRMA LA TRX EN BD POR CADA REGISTRO PROCESADO CON O SIN ERROR
                     COMMIT;
    
                     IF v_indicador_proceso <> pac_msv_constantes.c_respuesta_exitosa THEN
                        EXIT; -- si encabezado no pudo ser registado en la tabla de cargue encabezado no se procesa el archivo
                     END IF;
                  ELSE

                     b_validacion_encabezado := FALSE;
                     t_tmp_cargue(idx).observaciones := v_observacion_proceso;
                     t_tmp_cargue(idx).estado := pac_msv_constantes.c_estado_cargue_inconsistente;
                     --Registro en el historico del cargue
                     pr_gu_historico(t_tmp_cargue(idx) ,p_usuario_in);
                     -- CONFIRMA LA TRX EN BD POR CADA REGISTRO PROCESADO CON O SIN ERROR
                     COMMIT;
                     EXIT; -- si encabezado tiene errores de estructura no se procesa el archivo
                  END IF;
                ELSE

                  NULL;
                 -- CONTINUE;
                END IF;
             ELSE

               --Se obtiene el arreglo con la informacion del cargue
               IF (p_tipo_cargue_in = pac_msv_constantes.c_tipo_cargue_devoluciones) THEN -- CARGUE DE DEVOLUCIONES cargue con columnas separadas por comas sin ancho fijo
                  t_tmp_array := pac_msv_utilidades.fu_split(t_tmp_cargue(idx).texto, pac_msv_constantes.c_caracter_coma);
               ELSE -- todos los demas cargues de BCS son cargue con columnas con ancho fijo, separadas por comas
                  t_tmp_array := pac_msv_utilidades.fu_obtener_delim(t_tmp_cargue(idx).texto, v_parametro,pac_msv_constantes.c_caracter_coma);
               END IF;
               n_total_cargue := n_total_cargue + 1;
               IF v_valida_detalles = c_s 
               THEN
               --Validaciones segun el tipo de cargue: Ventas Diarias, Facturacion, otros..

                     pr_valida_cargue_masivo(
                       p_tipo_cargue_in
                       ,t_tmp_array
                       ,p_usuario_in
                       ,v_indicador_proceso
                       ,v_observacion_proceso);

                 --INI 51746 14/08/2019
                 --Validacion facturas
                 IF p_tipo_cargue_in = pac_msv_constantes.c_tipo_cargue_facturacion AND
                    v_indicador_proceso = pac_msv_constantes.c_respuesta_exitosa THEN

                   --
                   --DECODE (v_tipo_poliza, 'COL', 2, 1)
                   SELECT DECODE (TRIM(SUBSTR(t_tmp_cargue(idx).TEXTO,21,4)), 'COL', 2, 1) INTO n_tipo_poliza FROM DUAL;
                   IF n_tipo_poliza <> n_sproduc THEN
                     --
                     v_indicador_proceso :=  pac_msv_constantes.c_fallo_error_datos;
                     v_observacion_proceso  := pac_msv_utilidades.fu_valor_parametro  (c_cod_error_modalidad,c_grupo_error_gasera);
                     --
                   END IF;
                 END IF;

                 --FIN 51746 14/08/2019
               ELSE
                 v_indicador_proceso := pac_msv_constantes.c_respuesta_exitosa;
               END IF;

               --Guarda el registro en la respectiva tabla destino
               IF v_indicador_proceso = pac_msv_constantes.c_respuesta_exitosa 
               -- INICIO PYALLTIT
               AND p_tipo_cargue_in <> 'AS' THEN
               -- FIN PYALLTIT

                     pr_gu_por_tipo_cargue(
                         p_id_cargue_in
                        ,p_tipo_cargue_in
                        ,t_tmp_cargue(idx)
                        ,t_tmp_array
                        ,p_usuario_in
                        ,v_indicador_proceso);

               -- INICIO PYALLTIT
               ELSIF v_indicador_proceso = pac_msv_constantes.c_respuesta_exitosa AND p_tipo_cargue_in = 'AS' THEN

      t_tmp_array := pac_msv_utilidades.fu_split(t_tmp_cargue(idx).texto, pac_msv_constantes.c_caracter_coma);


                     pr_gu_por_tipo_cargue_AS(
                         p_id_cargue_in
                        ,p_tipo_cargue_in
                        ,t_tmp_cargue(idx)
                        ,t_tmp_array
                        ,p_usuario_in
                        ,v_indicador_proceso);

               -- FIN PYALLTIT
               END IF;
               --
               IF v_indicador_proceso = pac_msv_constantes.c_respuesta_exitosa THEN
                  n_total_exitoso := n_total_exitoso + 1;
                  t_tmp_cargue(idx).estado := pac_msv_constantes.c_estado_cargue_exitoso;
               ELSE
                  n_total_fallido := n_total_fallido + 1;
                  t_tmp_cargue(idx).observaciones := v_observacion_proceso;
                  t_tmp_cargue(idx).estado := pac_msv_constantes.c_estado_cargue_inconsistente;

               END IF;

               --Registro en el historico del cargue
               pr_gu_historico(t_tmp_cargue(idx) ,p_usuario_in);
               -- CONFIRMA LA TRX EN BD POR CADA REGISTRO PROCESADO CON O SIN ERROR
               COMMIT;
             --
             END IF;
           --
           END LOOP;
        --
        END LOOP;

        --Se inicializa como exitoso el estado del cargue
        v_estado_cargue := pac_msv_constantes.c_estado_cargue_exitoso;

        IF NOT(b_validacion_encabezado) THEN
          p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
          p_indicador_proceso_out   := v_observacion_proceso;
          v_estado_cargue := pac_msv_constantes.c_estado_cargue_inconsistente;
        ELSIF (b_validacion_encabezado AND n_total_exitoso != n_total_cargue) THEN
          p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
          p_observacion_proceso_out := pac_msv_utilidades.fu_valor_parametro(c_cod_error_inconsistencias,c_grupo_error_gasera);
          v_estado_cargue := pac_msv_constantes.c_estado_cargue_inconsistente;
        END IF;

        --Se actualiza la cantidad de registros procesados
        update msv_tb_cargue_masivo
        set total_registros = n_total_cargue
            ,total_gestionados = n_total_gestionado
            ,total_pendientes = n_total_pendiente
            ,total_exitosos = n_total_exitoso
            ,total_fallidos = n_total_fallido
            ,estado_cargue = v_estado_cargue
--12.0
--18.0
            --,estado_proceso = pac_msv_constantes.c_estado_cargue_terminado
--18.0
--12.0
            ,fecha_modificacion = current_timestamp	   								   
        where id = p_id_cargue_in;

        -- CONFIRMA LA TRX EN BD
        COMMIT;
      --
      END registrar_detalle;

  --
  END IF;

  <<limpiar_cargue_detalle>>
  BEGIN

    --
  NULL;
  EXCEPTION

  WHEN OTHERS THEN

      pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
          p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
          ,p_ntraza_in          => 2821
          ,p_mensaje_in         => v_parametros||SQLCODE || ' @ ' ||  SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
          ,p_usuario_in         => p_usuario_in
          ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
        );
  END limpiar_cargue_detalle;

--
 EXCEPTION
  WHEN EXCEPTION_PRODUCTO THEN
         p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;

       p_observacion_proceso_out := pac_msv_utilidades.fu_valor_parametro
        (
           c_cod_error_tipo_producto
          ,c_grupo_error_gasera
        );
       pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
          p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
          ,p_ntraza_in          => 2821
          ,p_mensaje_in         => p_observacion_proceso_out||SQLCODE || ' @ ' ||  SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
          ,p_usuario_in         => p_usuario_in
          ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
        );
 WHEN OTHERS THEN
    p_indicador_proceso_out   := pac_msv_constantes.c_fallo_error_datos;
    p_observacion_proceso_out := pac_msv_utilidades.fu_valor_parametro
      (
        c_cod_error_inconsistencias
        ,c_grupo_error_gasera
      );

    --ROLLBACK TO inicia_cargue;
    -- INICIO - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
    --    delete msv_tb_cargue_masivo where id = p_id_cargue_in;
    -- FIN - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
    pac_msv_utilidades.PR_REGISTRAR_EN_LOG(
        p_nombre_objeto_in   => c_nombre_paquete||'.'||c_nombre_procedimiento
        ,p_ntraza_in          => 2843
        ,p_mensaje_in         => v_parametros||SQLCODE || ' @ ' ||  SQLERRM||' @ '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
        ,p_usuario_in         => p_usuario_in
        ,p_tipo_mensaje_in    => pac_msv_constantes.C_TIPO_MENSAJE_ERROR
      );
END pr_procesa_cargue_masivo;
-- INICIO PYALLTIT
FUNCTION f_alta_certif(pnpoliza IN NUMBER, p_id_cargue_in IN NUMBER,p_TIPO IN NUMBER,p_NUMID IN VARCHAR2, P_NLINEA IN NUMBER, P_NPLAN IN NUMBER,P_RECIBO IN NUMBER) RETURN NUMBER IS
-------------------------------------------------------------------------------------
      pcempres NUMBER;
      vsproduc NUMBER;
      pfefecto DATE;
      psproces NUMBER;
      pnlinea NUMBER;
      pcestado NUMBER;
      pcramo NUMBER;
      pcmodali NUMBER;
      pctipseg NUMBER;
      pccolect NUMBER;
      psperson_promo NUMBER;
      psperson_asseg NUMBER;
      pcbancar_promo VARCHAR2(1000);
      pcbancar_asseg VARCHAR2(1000);
      pcdomici_promo NUMBER;
      pcdomici_asseg NUMBER;
      piapoini_promo NUMBER;
      piapoini_asseg NUMBER;
      piprianu NUMBER;
      papor_promo NUMBER;
      piapor_promo NUMBER;
      pfcarpro_promo DATE;
      pfcarpro_asseg DATE;
      pcforpag_promo NUMBER;
      pcforpag_asseg NUMBER;
      pcrevali NUMBER;
      pprevali NUMBER;
      pfrevali DATE;
      ptbenef1 VARCHAR2(1000);
      ptbenef2 VARCHAR2(1000);
      ptbenef3 VARCHAR2(1000);
      ppolissa_ini NUMBER;
      pcidioma NUMBER;
      pcoficin NUMBER;
      pfvencim DATE;
      pcactivi NUMBER;
      num_recibo NUMBER;
      ptnatrie VARCHAR2(1000);
      pmoneda NUMBER(14);
      pcfiscal_promo NUMBER(14);
      pcfiscal_asseg NUMBER(14);
      ppimport_promo NUMBER(14);
      ppimport_asseg NUMBER(14);
      piimport_promo NUMBER(14);
      piimport_asseg NUMBER(14);
      pcobrar NUMBER(14);
      psseguro NUMBER(14);
        nExistePer        NUMBER;
        nExisteAseg       NUMBER;
        PSSEGUROASEG      NUMBER;
        NSPERSON          NUMBER;
        cPOLIZA           VARCHAR2(4000);
        cPrimerNombre     VARCHAR2(4000);	
        cSegundoNombre    VARCHAR2(4000);	
        cPrimerApellido   VARCHAR2(4000);
        cSegundoApellido  VARCHAR2(4000);
        cTipoIdentificacion        VARCHAR2(4000);	
        cNumeroIdentificacion      VARCHAR2(4000);	
        cGenero                    VARCHAR2(4000);	
        cFechaNacimiento           VARCHAR2(4000);	
        cFechaingresopoliza        VARCHAR2(4000);
        cPlan                      VARCHAR2(4000);
        cCodigo                    VARCHAR2(4000);	
        cCursoSede                 VARCHAR2(4000);
        --INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB
        cCorreoelectronico         VARCHAR2(4000);        
        TVALORDIN                  VARCHAR2(4000);        
        pmodo           VARCHAR2(4000) := 'R';
        pcmovimi        NUMBER ;
        xcforpag_rec    NUMBER := 1;
        pttabla         VARCHAR2(4000);
        pfuncion        VARCHAR2(4000) := 'CAR';
        pcdomper        NUMBER := 0; 
        TOTALPRIMA      NUMBER ;
        NRNRECIBO       NUMBER ;
        VCTX NUMBER;

        --FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB
        pcagente  SEGUROS.cagente%TYPE; 
        pfemisio  SEGUROS.femisio%TYPE;  
        pfvencimi SEGUROS.FRENOVA%TYPE;  
        pctiprec  RECIBOS.ctiprec%TYPE := 0; 
        pnanuali  SEGUROS.nanuali%TYPE;  
        pnfracci  SEGUROS.nfracci%TYPE;  
        pccobban  SEGUROS.ccobban%TYPE;  
        pcestimp  RECIBOS.cestimp%TYPE := 0; 
        nSqlerrm     VARCHAR2(4000);
        nSqlCode     NUMBER;
        cObservaTrz  VARCHAR2(4000);
        nExisteError NUMBER;
-------------------------------------------------------------------------------------
      lncertif       NUMBER;
      lccobban       NUMBER;
      lprod          productos%ROWTYPE;
      lproducte      VARCHAR2(4);
      l282           garanpro%ROWTYPE;
      l48            garanpro%ROWTYPE;
      lnmovimi       NUMBER;
      num_err        NUMBER;
      lnorden_promo  NUMBER;
      lnorden_asseg  NUMBER;
      lnordcla       NUMBER;
      lindice        NUMBER;
      lindice_e      NUMBER;
      lindice_t      NUMBER;
      lnrecibo       NUMBER;
      llinea         NUMBER;
      lsmovagr       NUMBER := 0;
      lnliqmen       NUMBER;
      lnliqlin       NUMBER;
      lnparpla       NUMBER;
      lcdelega       NUMBER;
      lparticipacion NUMBER;
      lnsuplem       NUMBER;
      ldivisa        NUMBER;
      lfmovini       DATE;
      pmensaje       VARCHAR2(500);   -- BUG 27642 - FAL - 30/04/2014
      --- INICIO PYALLTIT  06062020
      nEDADASEGURADO  NUMBER;
      vnumerr         NUMBER;
      dFVENCIM          DATE;
      dFEFECTO          DATE;
      nDiasCobrar     NUMBER;
      nPeriodo          NUMBER;
      --- FIN PYALLTIT  06062020
      CPORCENTAJE  NUMBER;
    --- INICIO PYALLTIT  17072020   
      v_numerr2         NUMBER;
      nExisteDireccion  NUMBER;
      nExisteTomador    NUMBER;
      CCAGENTE          NUMBER;
      --- FIN PYALLTIT  17072020 									  						 
      --  INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
      v_ctipcom         NUMBER;
      v_iprianu         NUMBER;
      v_concep          NUMBER;
      v_coacedido       NUMBER;
      v_tienecoaseg     NUMBER;
      v_sseguro_0       NUMBER;
      v_comisi          NUMBER;
      v_cforpag         NUMBER;
      v_concep_cb       NUMBER;
      v_coadev          NUMBER; 
      v_comdev          NUMBER;
      v_porcprim        NUMBER;
      v_cdomici         NUMBER;
      --  FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
      -- INICIO -  29/08/2020 - Company - AR 37070 - Incidencias HU-EMI-PW-APGP-012
      v_PrimerNombre     VARCHAR2(4000);	
      v_SegundoNombre    VARCHAR2(4000);	
      v_PrimerApellido   VARCHAR2(4000);
      v_SegundoApellido  VARCHAR2(4000);
      v_NumeroIdentificacion      VARCHAR2(4000);	
      v_Genero                    VARCHAR2(4000);	
      v_FechaNacimiento           VARCHAR2(4000);
      -- FIN -  29/08/2020 - Company - AR 37070 - Incidencias HU-EMI-PW-APGP-012
      -- INICIO -  27/08/2020 - Company - AR 37035 - Incidencias HU-EMI-APGP-017
      v_crespue          NUMBER := 0;
      -- FIN -  27/08/2020 - Company - AR 37035 - Incidencias HU-EMI-APGP-017
      -- INICIO - 08/09/2020 - Company - AR 37175 - Incidencias HU-EMI-PW-APGP-012
      v_cagente          NUMBER;
      v_cpoblac          NUMBER;
      v_cprovin          NUMBER;
      v_cpostal          NUMBER;
      -- FIN - 08/09/2020 - Company - AR 37175 - Incidencias HU-EMI-PW-APGP-012
      v_fcarant          DATE;
      -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      nFactor            NUMBER;
      v_coapos           NUMBER:=0;
      v_multiplo         NUMBER;
      v_fcarpro      DATE;
      -- fecha vencimiento caratula
      v_fvenccar         DATE;
      -- fecha fin recibo
      v_ffinrec          DATE;
      -- fecha efecto certificado
      v_fefectocert      DATE;
      -- diferencia dias
      v_difdias          NUMBER;
      -- diferencia dias valida
      v_difdiasval       NUMBER;
      -- diferencia dias anular
      v_difdiasanu       NUMBER;
      -- Factor neto
      v_facnet           NUMBER;
      -- Factor devolver
      v_facdev           NUMBER;
      -- prima anual
      v_prianu           NUMBER;
      -- prima por factor neto
      v_prifacnet        NUMBER;
      -- Prima por factor devolver
      v_prifacdev        NUMBER;
      -- Fecha recibo anterior
      v_frecant          DATE;
      -- Fecha proximo recibo
      v_fcaranu          DATE;
      nerror             NUMBER;
      -- mes fecha de efecto certificado
      v_mesfefecto       NUMBER;
      -- no prorratea
      v_noprorrat        BOOLEAN := FALSE;
      -- calcula la diferencia en recibos retroactivos (despues de renovar se incluye asegurado antes de renovacion)
      v_difdias2         NUMBER;
      -- valida si el recibo va a ser retroactivo para que se genere el calculo del factor
      v_recretroact      BOOLEAN := FALSE;
      -- valida si la fecha de efecto de certificado y carÃ¡tula son diferentes en recibos retroactivos y aplica prorrata
      v_recretroprorr    BOOLEAN := FALSE;
      -- Permiten validar si el aÃ±o de efecto es bisiesto o no para calcular el factor de liquidacion de dias
      v_diasanio         NUMBER;
      v_diasfeb          NUMBER;
      -- Valida si ya se hizo renovacion y tiene fecha de recibo anterior
      v_fcarantcar       DATE;
      v_fcarprocar       DATE;
      -- dia fecha de efecto certificado
      v_diafefecto       NUMBER;

      v_diafefectocar    NUMBER;
      v_mesfcarprocar    NUMBER;
      v_mesfefectocert   NUMBER;
      v_primdiamesfefecto DATE;
      -- numero de periodos adicionales a sumar
      v_peradic          NUMBER;

      v_aniofcarprocar   NUMBER;
      v_aniofefectocert  NUMBER;
      -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
      cDireccion         INT_CARGA_GENERICO.CAMPO19%TYPE;
      cDepartamento      INT_CARGA_GENERICO.CAMPO20%TYPE;
      cCiudad            INT_CARGA_GENERICO.CAMPO21%TYPE;
      cTelefono          INT_CARGA_GENERICO.CAMPO22%TYPE;
      cCelular           INT_CARGA_GENERICO.CAMPO23%TYPE;
      v_cmodcon          PER_CONTACTOS.CMODCON%TYPE;
      v_existcdom1       PER_DIRECCIONES.CDOMICI%TYPE;
      -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
      -- INICIO - 24/03/2021 - Company - Ar 37175
      v_sperson_tomador  TOMADORES.SPERSON%TYPE;
      v_cdomici_t        TOMADORES.CDOMICI%TYPE;
      v_tdomici_t        PER_DIRECCIONES.TDOMICI%TYPE;
      v_cpoblac_t        PER_DIRECCIONES.CPOBLAC%TYPE;
      v_cprovin_t        PER_DIRECCIONES.CPROVIN%TYPE;
      v_valcontel_t      PER_CONTACTOS.TVALCON%TYPE;
      v_valconcel_t      PER_CONTACTOS.TVALCON%TYPE;
      v_valconemail_t    PER_CONTACTOS.TVALCON%TYPE;
      v_cdomici_a        PER_DIRECCIONES.CDOMICI%TYPE;
      v_tdomici_a        PER_DIRECCIONES.TDOMICI%TYPE;
      v_tvalcontel_a     PER_CONTACTOS.TVALCON%TYPE;
      v_cmodconnext      PER_CONTACTOS.CMODCON%TYPE;
      v_existetel_a      NUMBER := 0;
      v_tvalconcel_a     PER_CONTACTOS.TVALCON%TYPE;
      v_tvalconemail_a   PER_CONTACTOS.TVALCON%TYPE;
      v_existemail_a     NUMBER := 0;
      -- FIN - 24/03/2021 - Company - Ar 37175
      v_sperson          PER_PERSONAS.SPERSON%TYPE;
   BEGIN
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '3994 INICIA F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
   --- INICIO PYALLTIT
   BEGIN
    -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
    --SELECT DECODE(CFORPAG,0,1,CFORPAG) , FVENCIM, FEFECTO, FCARANT
    SELECT DECODE(CFORPAG,0,1,CFORPAG) , FVENCIM, FEFECTO, NVL(FCARANT,FCARPRO), FCARPRO
    INTO   xcforpag_rec,dFVENCIM,dFEFECTO,v_fcarant, v_fcarpro
    -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
    FROM   SEGUROS S 
    WHERE S.NPOLIZA = pnpoliza
    AND   S.NCERTIF = 0;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
          xcforpag_rec :=0;
    END;    
   --- FIN PYALLTIT

            nExisteError := 0;
            BEGIN
              SELECT CSITUAC,cmodali,ccolect,ctipseg,cramo,fefecto,cactivi, NVL(Cmoneda,8), cidioma,cempres,sproduc,
              cagente, femisio, FRENOVA, nanuali, nfracci, ccobban
              INTO pcestado,pcmodali,pccolect,pctipseg,pcramo,pfefecto,pcactivi, pmoneda, pcidioma,pcempres,vsproduc,
              pcagente, pfemisio, pfvencimi, pnanuali, pnfracci, pccobban
              FROM seguros
              WHERE npoliza = pnpoliza
              AND   NCERTIF = 0;
            EXCEPTION
               WHEN OTHERS THEN
                  nExisteError := 1;
                  p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT SEGUROS :' || SQLERRM, SQLERRM);
            END;

      IF pcestado not in (0,5) AND nExisteError = 0 THEN
       cObservaTrz := 'Poliza no Vigente: '||cObservaTrz;
      END IF;
      nExisteError := 0;

      IF pcestado in( 0,5) THEN
         -- Obtenim el no de certificat per la polisa
         BEGIN
            SELECT NVL(MAX(ncertif), 0) + 1
              INTO lncertif
              FROM seguros
             WHERE npoliza = pnpoliza;
         EXCEPTION
            WHEN OTHERS THEN
               nExisteError := 1;
               p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT lncertif SEGUROS = ' || SQLERRM, SQLERRM);
             --  RETURN 100500;
         END;
        IF nExisteError = 0 THEN 
         cObservaTrz := 'No. Certificado Obtenido: '||lncertif;
        END IF; 

         -- Obtenim les dades del producte
         nExisteError := 0;
         BEGIN
            SELECT *
              INTO lprod
              FROM productos
             WHERE cramo = pcramo
               AND cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg;
         EXCEPTION
            WHEN OTHERS THEN
               nExisteError := 1;
               p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PRODUCTOS = ' || SQLERRM, SQLERRM);
             --  RETURN 102705;
         END;
         -- Obtenir cobrador bancari
         nExisteError := 0;
         BEGIN
            SELECT ccobban
              INTO lccobban
              FROM cobbancariosel
             WHERE cramo = pcramo
               AND cmodali = pcmodali
               AND ctipseg = pctipseg
               AND ccolect = pccolect;
         EXCEPTION
            WHEN TOO_MANY_ROWS THEN
               SELECT MIN(ccobban)
                 INTO lccobban
                 FROM cobbancariosel
                WHERE cramo = pcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect;
            WHEN NO_DATA_FOUND THEN
            -- INICIO - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
               SELECT MIN(ccobban)
                 INTO lccobban
                 FROM cobbancariosel
                WHERE cramo = pcramo
                  AND ROWNUM = 1;
            WHEN OTHERS THEN
            -- FIN - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
               lccobban := NULL;
               nExisteError := 1;
               p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT ccobbancariosel = ' || SQLERRM, SQLERRM);
         END;

         -- Obtenim la seq. de seguros
         nExisteError := 0;
         BEGIN
            SELECT sseguro.NEXTVAL
              INTO psseguro
              FROM DUAL;
         EXCEPTION
            WHEN OTHERS THEN
               nExisteError := 1;
               p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT sseguro.nextval = ' || SQLERRM, SQLERRM);
               --  RETURN 140719;
         END;

         --Dades i insert a CNVPOLIZAS
         nExisteError := 0;
         BEGIN
            SELECT sistema
              INTO lproducte
              FROM cnvproductos
             WHERE cramo = pcramo
               AND cmodal = pcmodali
               AND ctipseg = pctipseg
               AND ccolect = pccolect;
         EXCEPTION
            -- INICIO - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
            WHEN NO_DATA_FOUND THEN
              lproducte := NULL;
            -- FIN - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
            WHEN OTHERS THEN
              -- lproducte := '';
               nExisteError := 1;
               p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT CNVPRODUCTOS = ' || SQLERRM, SQLERRM);
         END;
         nExisteError := 0;
         BEGIN
            INSERT INTO cnvpolizas
                        (sseguro, sistema, polissa_ini, npoliza, producte, ram, moda,
                         tipo, cole)
                 VALUES (psseguro, 'MU', nvl(ppolissa_ini,pnpoliza), pnpoliza, lproducte, pcramo, pcmodali,
                         pctipseg, pccolect);
         EXCEPTION
            WHEN OTHERS THEN
               nExisteError := 1;
               p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT cnvpolizas = ' || SQLERRM, SQLERRM);
              -- RETURN 140757;
         END;
         IF nExisteError = 0 THEN
          cObservaTrz  := 'Insert Datos de cnvpolizas: '||psseguro||' '||cObservaTrz;
         END IF;
         nExisteError := 0;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '4147 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
         -- Insert a seguros
         BEGIN
            INSERT INTO seguros
                        (SSEGURO,CMODALI,CCOLECT,CTIPSEG,CASEGUR,CAGENTE,CRAMO,NPOLIZA,NCERTIF,NSUPLEM,  FEFECTO,   
                        CREAFAC,CTARMAN,COBJASE, CTIPREB,CACTIVI, CCOBBAN,CTIPCOA,CTIPREA,CRECMAN, CRECCOB,CTIPCOM,FVENCIM, FEMISIO,FANULAC,FCANCEL,
                        CSITUAC,CBANCAR,CTIPCOL,FCARANT,   FCARPRO,      FCARANU, CDURACI,NDURACI,NANUALI,   IPRIANU,  CIDIOMA,  NFRACCI,CFORPAG,  
                        PDTOORD,NRENOVA,  CRECFRA, TASEGUR,CRETENI,NDURCOB,  SCIACOA,PPARCOA,NPOLCOA,NSUPCOA,TNATRIE,PDTOCOM,PREVALI,IREVALI,NCUACOA,
                        NEDAMED,CREVALI,CEMPRES,CAGRPRO,NSOLICI, FIMPSOL,SPRODUC,CCOMPANI,INTPRES,NMESCOB,CNOTIBAJA,CCARTERA,NPARBEN,NBNS, CTRAMO,
                        CINDEXT,PDISPRI,IDISPRI,CIMPASE,CAGENCORR,NPAGINA, NLINEA,CTIPBAN,CTIPCOB,   SPRODTAR,CSUBAGE,CPOLCIA,CPROMOTOR,CMONEDA,
                        NCUOTAR,CTIPRETR, CINDREVFRAN,PRECARG,PDTOTEC,PRECCOM,FRENOVA,CBLOQUEOCOL,NEDAMAR,CTIPOASIGNUM,NPOLIZAMANUAL,NPREIMPRESO,
                        PROCESOCARGA,FEFEPLAZO,FVENCPLAZO,NCARGA,CCONVPAGO,TINTERES,       DPAGO)
           (SELECT       psseguro,CMODALI,CCOLECT,CTIPSEG,CASEGUR,CAGENTE,CRAMO,NPOLIZA,lncertif,1,  
           PAC_POS_CARGUE.dFechaIngreso FEFECTO,   
            -- INICIO - 19/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
            --CREAFAC,CTARMAN,COBJASE, CTIPREB,CACTIVI, CCOBBAN,CTIPCOA,CTIPREA,CRECMAN, CRECCOB,CTIPCOM,FVENCIM, FEMISIO,FANULAC,FCANCEL,
            CREAFAC,CTARMAN,COBJASE, CTIPREB,CACTIVI, CCOBBAN,CTIPCOA,CTIPREA,CRECMAN, CRECCOB,CTIPCOM,NULL, FEMISIO,FANULAC,FCANCEL,
            -- FIN - 19/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
            0,CBANCAR,CTIPCOL,FCARANT,   FCARPRO,      FCARANU, CDURACI,NDURACI,NANUALI,   IPRIANU,  CIDIOMA,  NFRACCI,CFORPAG,  
            -- INICIO - 19/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
            --PDTOORD,NRENOVA,  CRECFRA, TASEGUR,CRETENI,NDURCOB,  SCIACOA,PPARCOA,NPOLCOA,NSUPCOA,TNATRIE,PDTOCOM,PREVALI,IREVALI,NCUACOA,
            PDTOORD,NRENOVA,  CRECFRA, TASEGUR,CRETENI,NDURCOB,  SCIACOA,PPARCOA,NPOLCOA,NSUPCOA,TNATRIE,PDTOCOM,PREVALI,0,NCUACOA,
            -- FIN - 19/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
            NEDAMED,CREVALI,CEMPRES,CAGRPRO,NSOLICI, FIMPSOL,SPRODUC,CCOMPANI,INTPRES,NMESCOB,CNOTIBAJA,CCARTERA,NPARBEN,NBNS, CTRAMO,
            CINDEXT,PDISPRI,IDISPRI,CIMPASE,CAGENCORR,NPAGINA, NLINEA,CTIPBAN,CTIPCOB,   SPRODTAR,CSUBAGE,CPOLCIA,CPROMOTOR,CMONEDA,
            -- INICIO - 19/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
            --NCUOTAR,CTIPRETR, CINDREVFRAN,PRECARG,PDTOTEC,PRECCOM,FRENOVA,CBLOQUEOCOL,NEDAMAR,CTIPOASIGNUM,NPOLIZAMANUAL,NPREIMPRESO,
            NCUOTAR,CTIPRETR, CINDREVFRAN,PRECARG,PDTOTEC,PRECCOM,FRENOVA,0,NEDAMAR,CTIPOASIGNUM,NPOLIZAMANUAL,NPREIMPRESO,
            -- FIN - 19/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
            PROCESOCARGA,FEFEPLAZO,FVENCPLAZO,NCARGA,CCONVPAGO,TINTERES,DPAGO
             FROM SEGUROS
             WHERE NPOLIZA = pnpoliza
             AND   NCERTIF = 0);    

         EXCEPTION
            WHEN OTHERS THEN
               nExisteError := 1;
               p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT SEGUROS = ' || SQLERRM, SQLERRM);
              -- RETURN 110165;
         END;

        -- INICIO - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
        v_ncertif := lncertif;
        /*
        BEGIN
        -- INICIO PYALLTIT 06062020
        --TVALORDIN :=  pnpoliza||'-'||lncertif; 
        TVALORDIN :=  lncertif;
        -- FIN PYALLTIT 06062020
        TVALORDFIN := TVALORDFIN||';'||TVALORDIN;  
       END;
       */
       -- FIN - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
         IF nExisteError = 0 THEN
          cObservaTrz  := 'Insert Datos de polizas: '||psseguro||' lncertif: '||lncertif||' '||cObservaTrz;
         END IF;
         -- inicialitzem nsuplem
         lnsuplem := 1;

         -- Insertem el moviment, el primer es de nova produccion       
        -- INICIO - Company  20/04/2021 Ar 37659
        --num_err := f_movseguro_POSI(psseguro, NULL, 100, 0, pfefecto, NULL, 0, 0, NULL, lnmovimi,
        num_err := f_movseguro_POSI(psseguro, NULL, 100, 0, PAC_POS_CARGUE.dFechaIngreso, NULL, 0, 0, NULL, lnmovimi,
        -- FIN - Company - 20/04/2021 Ar 37659
                                NULL, NULL, NULL, NULL);

         IF nExisteError = 0 THEN
          cObservaTrz  := 'Insert Datos de Movseguro: '||psseguro||' lncertif: '||lncertif||' lnmovimi: '||lnmovimi||' '||cObservaTrz;
         END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '4213 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
         nExisteError := 0;
         -- Insertem historicooficinas
         BEGIN
            INSERT INTO historicooficinas
                        (sseguro, finicio, ffin, coficin)
                 VALUES (psseguro, pfefecto, NULL, pcoficin);
         EXCEPTION
            WHEN OTHERS THEN
               nExisteError := 1;
               p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT HISTORICOOFICINAS ', SQLERRM);
              -- RETURN 140721;
         END;

         IF nExisteError = 0 THEN
          cObservaTrz  := 'Insert Datos de historicooficinas: '||psseguro||' lncertif: '||lncertif||' lnmovimi: '||lnmovimi||' pcoficin: '||pcoficin||' '||cObservaTrz;
         END IF;
        --  INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
        -- Se valida si tiene coaseguro cedido
        BEGIN
          SELECT COUNT(*)
          INTO v_tienecoaseg
          FROM COACUADRO
          WHERE sseguro = (SELECT sseguro FROM seguros WHERE npoliza = pnpoliza AND ncertif = 0);
        EXCEPTION
          WHEN OTHERS THEN
            v_tienecoaseg := 0;
        END;
        IF v_tienecoaseg > 0 THEN
          -- Se inserta el cuadro de coaseguro
          BEGIN
            INSERT INTO COACUADRO (SSEGURO,NCUACOA,FINICOA,FFINCOA,PLOCCOA,FCUACOA,CCOMPAN,NPOLIZA)
            SELECT psseguro, ncuacoa, finicoa, ffincoa, ploccoa, fcuacoa, ccompan, npoliza
                    FROM coacuadro 
                    WHERE sseguro  = (SELECT sseguro FROM seguros WHERE npoliza = pnpoliza AND ncertif = 0)
                    AND ncuacoa = (SELECT MAX(NCUACOA) FROM coacuadro WHERE SSEGURO = (SELECT sseguro FROM seguros WHERE npoliza = pnpoliza AND ncertif = 0));
          EXCEPTION
            WHEN OTHERS THEN
               nExisteError := 1;
               nSqlerrm     := Sqlerrm;
               nSqlCode     := SqlCode;
               cObservaTrz  := 'Insert Datos de : Error '||nSqlCode||' '||nSqlerrm;
               p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT COACUADRO cObservaTrz = ' || cObservaTrz, SQLERRM);
              -- RETURN 140721;
          END;
          IF nExisteError = 0 THEN
            cObservaTrz  := 'Insert Datos de historicooficinas: '||psseguro||' lncertif: '||lncertif||' lnmovimi: '||lnmovimi||' pcoficin: '||pcoficin||' '||cObservaTrz;
          END IF;
          -- Se inserta el porcentaje de coaseguro cedido
          BEGIN
            INSERT INTO COACEDIDO (SSEGURO,NCUACOA,CCOMPAN,PCESCOA,PCOMCOA,PCOMCON,PCOMGAS,PCESION) 
            SELECT psseguro, ncuacoa, ccompan,pcescoa,pcomcoa, pcomcon,pcomgas, pcesion
            FROM coacedido WHERE sseguro  = (SELECT sseguro FROM seguros WHERE npoliza = pnpoliza AND ncertif = 0)
            AND ncuacoa = (SELECT MAX(ncuacoa) FROM coacedido WHERE sseguro = (SELECT sseguro FROM seguros WHERE npoliza = pnpoliza AND ncertif = 0));
          EXCEPTION
            WHEN OTHERS THEN
               nExisteError := 1;
               p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT COACEDIDO ', SQLERRM);
              -- RETURN 140721;
          END;
          IF nExisteError = 0 THEN
            cObservaTrz  := 'Insert Datos de historicooficinas: '||psseguro||' lncertif: '||lncertif||' lnmovimi: '||lnmovimi||' pcoficin: '||pcoficin||' '||cObservaTrz;
          END IF;
          BEGIN
            INSERT INTO comisionsegu(sseguro,cmodcom, pcomisi, ninialt, nfinalt,nmovimi)
            SELECT psseguro, cmodcom, pcomisi, ninialt, nfinalt,nmovimi
            FROM comisionsegu
            WHERE sseguro = (SELECT sseguro FROM seguros WHERE npoliza = pnpoliza AND ncertif = 0)
            AND cmodcom = 1;
          EXCEPTION
            WHEN OTHERS THEN
               nExisteError := 1;
               p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT COMISIONSEGU ', SQLERRM);
              -- RETURN 140721;
          END;
          BEGIN
            INSERT INTO comisionsegu(sseguro,cmodcom, pcomisi, ninialt, nfinalt,nmovimi)
            SELECT psseguro, cmodcom, pcomisi, ninialt, nfinalt,nmovimi
            FROM comisionsegu
            WHERE sseguro = (SELECT sseguro FROM seguros WHERE npoliza = pnpoliza AND ncertif = 0)
            AND cmodcom = 2;
          EXCEPTION
            WHEN OTHERS THEN
               nExisteError := 1;
               p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT COMISIONSEGU ', SQLERRM);
              -- RETURN 140721;
          END;
        END IF;
        --  FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
         -- Insertem el prenedor
         nExisteError := 0;
--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB         
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '4309 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
        BEGIN
          SELECT COUNT(*)
          INTO nExistePer
          FROM PER_PERSONAS
          WHERE CTIPIDE = p_TIPO
          AND   NNUMIDE = p_NUMID;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             nExistePer := 0;
        END;
        nExisteError := 0;

--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB
        BEGIN
        SELECT DISTINCT CAMPO01,CAMPO02,CAMPO03,CAMPO04,CAMPO05,	CAMPO06,	CAMPO07,	DECODE(CAMPO08,'M',1,'F',2) CAMPO08,
        CAMPO09,	CAMPO10,	
               CAMPO11,	CAMPO12,CAMPO13 ,CAMPO14
        -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
        , CAMPO19, CAMPO20, CAMPO21, CAMPO22, CAMPO23
        -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
        INTO cPOLIZA,cPrimerNombre,	cSegundoNombre,	cPrimerApellido	,cSegundoApellido,	cTipoIdentificacion,	
             cNumeroIdentificacion,	cGenero,	cFechaNacimiento,	cFechaingresopoliza	,cPlan,	cCodigo,	cCursoSede, cCorreoelectronico
        -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
        , cDireccion, cDepartamento, cCiudad, cTelefono, cCelular
        -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
        FROM INT_CARGA_GENERICO
        WHERE PROCESO   = p_id_cargue_in
        AND   NCARGA    =  p_id_cargue_in
        AND   TIPO_OPER = 'AS'
        AND   NLINEA    = P_NLINEA;        
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
           cPOLIZA := null; cPrimerNombre := null; 	cSegundoNombre := null; 	cPrimerApellido	 := null; cSegundoApellido := null; 	cTipoIdentificacion := null; 	
           cNumeroIdentificacion := null; 	cGenero := null; 	cFechaNacimiento := null; 	cFechaingresopoliza := null; cPlan := null; 	cCodigo := null; 	cCursoSede := null; 
           nExisteError := 1;
           p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT INT_CARGA_GENERICO ', SQLERRM);
        END;

        -- INICIO - 24/03/2021 - Company - Ar 37175
        -- Se toman los datos de direccion y contacto del tomador para insertarlos en el asegurado si no los tiene
        BEGIN
          SELECT SPERSON, CDOMICI
          INTO v_sperson_tomador, v_cdomici_t
          FROM TOMADORES
          WHERE sseguro = (SELECT sseguro FROM seguros WHERE npoliza = pnpoliza AND ncertif = 0);
        EXCEPTION
          WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT tomadores ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
        END;

        BEGIN
          SELECT tdomici, cpoblac, cprovin
          INTO v_tdomici_t, v_cpoblac_t, v_cprovin_t
          FROM per_direcciones
          WHERE sperson = v_sperson_tomador
          AND CDOMICI = v_cdomici_t;
        EXCEPTION
          WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT per_direcciones ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
        END;

        -- Telefono fijo
        BEGIN
          SELECT tvalcon
          INTO v_valcontel_t
          FROM per_CONTACTOS
          WHERE sperson = v_sperson_tomador
          AND ctipcon = 1
          AND cmodcon = (select min(cmodcon) FROM per_CONTACTOS WHERE sperson = v_sperson_tomador and ctipcon = 1);
        EXCEPTION
          WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT per_contactos ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
        END;

        -- Telefono movil
        BEGIN
          SELECT tvalcon
          INTO v_valconcel_t
          FROM per_CONTACTOS
          WHERE sperson = v_sperson_tomador
          AND ctipcon in (5,6)
          AND cmodcon = (select min(cmodcon) FROM per_CONTACTOS WHERE sperson = v_sperson_tomador and ctipcon in (5,6));
        EXCEPTION
          WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT per_contactos ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
        END;

        -- Telefono movil
        BEGIN
          SELECT tvalcon
          INTO v_valconemail_t
          FROM per_CONTACTOS
          WHERE sperson = v_sperson_tomador
          AND ctipcon = 3
          AND cmodcon = (select min(cmodcon) FROM per_CONTACTOS WHERE sperson = v_sperson_tomador and ctipcon = 3);
        EXCEPTION
          WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT per_contactos ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
        END;

        -- FIN - 24/03/2021 - Company - Ar 37175

--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB       
         IF nExisteError <> 0 THEN
          cObservaTrz  := 'Consultar Datos de INT_CARGA_GENERICO: '||psseguro||' lncertif: '||lncertif||' lnmovimi: '||lnmovimi||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
         END IF;

         -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
         IF to_date(cFechaingresopoliza,'dd/mm/rr') >= v_fcarant THEN
         v_fcarant := v_fcarpro;
         END IF;
         -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo


          --- INICIO PYALLTIT  06062020
         nExisteError := 0;
         BEGIN
         nEDADASEGURADO := TRUNC(SYSDATE) - TO_DATE(cFechaNacimiento,'DD/MM/RRRR');
         EXCEPTION
          WHEN NO_DATA_FOUND THEN
           nExisteError := 1;
           p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION nEDADASEGURADO ', SQLERRM);
        END;
         IF nExisteError <> 0 THEN
          cObservaTrz  := 'Consultar Datos nEDADASEGURADO: '||psseguro||' lncertif: '||lncertif||' lnmovimi: '||lnmovimi||' pnpoliza: '||pnpoliza||' '||' cFechaNacimiento: '||cFechaNacimiento||' '||cObservaTrz;
         END IF;
         --- FIN PYALLTIT  06062020
        nExisteError := 0;
        IF nExistePer = 0 THEN
          -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
          BEGIN
            SELECT SPERSON.NEXTVAL
            INTO NSPERSON
            FROM DUAL FOR UPDATE;
          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT SPERSON.NEXTVAL ', SQLERRM);
          END;

          IF p_TIPO =  0 AND cNumeroIdentificacion IS NULL THEN
            vnumerr := f_snnumnif('Z', cNumeroIdentificacion);
          END IF;
          -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '4453 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB        
               BEGIN
                  -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
                  -- Se comenta para optimizar el codigo y controlar excepcion
                  --NSPERSON := SPERSON.NEXTVAL;

                  --- INICIO PYALLTIT  06062020
                  /*IF p_TIPO =  0 AND cNumeroIdentificacion IS NULL THEN
                     vnumerr := f_snnumnif('Z', cNumeroIdentificacion);
                  END IF;*/
                  --- FIN PYALLTIT  06062020
                  -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
                  INSERT
                  INTO PER_PERSONAS
                    (
                      SPERSON,
                      NNUMIDE,
                      NORDIDE,
                      CTIPIDE,
                      CSEXPER,
                      FNACIMI,
                      CESTPER,
                      FJUBILA,
                      CUSUARI,
                      FMOVIMI,
                      CMUTUALISTA,
                      FDEFUNC,
                      SNIP,
                      SWPUBLI,
                      CTIPPER,
                      TDIGITOIDE,
                      CPREAVISO,
                      CAGENTE,
                      CUSUALT,
                      FALTA
                    )
                    VALUES
                    (
                      NSPERSON,
                      cNumeroIdentificacion,
                      0,
                      p_TIPO, -- cTipoIdentificacion,
                      cGenero,
                      cFechaNacimiento,
                      0,
                      NULL,
                      F_USER,
                      to_date(cFechaingresopoliza,'DD/MM/YYYY'),
                      NULL,
                      NULL,
                      NULL,
                      1,
                      1, -- X.TipoPer,
                      '',
                      NULL,
                      --- INICIO PYALLTIT  06062020
                      17000, --120000, 
                      --- FIN PYALLTIT  06062020
                      F_USER,
                      F_SYSDATE
                    );
                    COMMIT;
       EXCEPTION
          WHEN OTHERS THEN
           nExisteError := 1;
           p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PER_PERSONAS ', SQLERRM);
       END;
        IF nExisteError = 0 THEN
        cObservaTrz  := 'Insert Datos de PER_PERSONAS: '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
       END IF;
       --- INICIO PYALLTIT  06062020
    /*  
       BEGIN
       Insert into PER_DIRECCIONES (SPERSON,CAGENTE,CDOMICI,CTIPDIR,CSIGLAS,TNOMVIA,NNUMVIA,TCOMPLE,TDOMICI,CPOSTAL,CPOBLAC,CPROVIN,CUSUARI,FMOVIMI,CVIAVP,CLITVP,CBISVP,CORVP,NVIAADCO,CLITCO,CORCO,NPLACACO,COR2CO,CDET1IA,TNUM1IA,CDET2IA,TNUM2IA,CDET3IA,TNUM3IA,IDDOMICI,LOCALIDAD,FDEFECTO,CMUNIC) 
       values (NSPERSON,'17000','1','1',null,null,null,null,'.',null,'1','54','79962359',to_date('10/06/20','DD/MM/RR'),null,null,null,null,null,null,null,null,null,null,null,null,null,null,'.',null,null,null,null);

       EXCEPTION
          WHEN OTHERS THEN
           nExisteError := 1;
           nSqlerrm     := Sqlerrm;
           nSqlCode     := SqlCode;
           cObservaTrz  := 'Insert Datos de PER_DIRECCIONES: Error '||nSqlCode||' '||nSqlerrm||' '||cObservaTrz;

       END;*/

       --- FIN PYALLTIT  06062020
--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB       
       --IF nExisteError = 0 THEN
        --cObservaTrz  := 'Insert Datos de PER_DIRECCIONES: '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
       --END IF;
       nExisteError := 0;

             BEGIN
                    INSERT
                    INTO PER_DETPER
                      (
                        SPERSON,
                        CAGENTE,
                        CIDIOMA,
                        TAPELLI1,
                        TAPELLI2,
                        TNOMBRE,
                        TSIGLAS,
                        CPROFES,
                        TBUSCAR,
                        CESTCIV,
                        CPAIS,
                        CUSUARI,
                        FMOVIMI,
                        TNOMBRE1,
                        TNOMBRE2,
                        COCUPACION
                      )
                      VALUES
                      (
                        NSPERSON,
                        --- INICIO PYALLTIT  06062020
                        17000, --120000,
                        --- FIN PYALLTIT  06062020
                        8,
                        cPrimerApellido,
                        cSegundoApellido,
                        cPrimerNombre
                        ||' '
                        ||cSegundoNombre,
                        '',
                        '',
                        '',
                        NULL,
                        170,
                        F_USER,
                        F_SYSDATE,
                        cPrimerNombre,
                        cSegundoNombre,
                        ''
                      );
        EXCEPTION
          WHEN OTHERS THEN
           nExisteError := 1;
           p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PER_DETPER ' , SQLERRM);
        END;     
         IF nExisteError = 0 THEN
         cObservaTrz  := 'Insert Datos de PER_DETPER: '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
         END IF;
----- daniel montenegro
      -- INICIO - 24/03/2021 - Company - Ar 37175
      /*
       -- INICIO - 08/09/2020 - Company - AR 37175 - Incidencias HU-EMI-PW-APGP-012

       BEGIN
         SELECT cagente
         INTO v_cagente
         FROM seguros
         WHERE npoliza = cPOLIZA
         AND ncertif = 0;
       EXCEPTION
         WHEN OTHERS THEN
           v_cagente:=17000;
       END;
       BEGIN
       SELECT cpoblac, cprovin, cpostal
         INTO v_cpoblac, v_cprovin, v_cpostal
         FROM per_direcciones
        WHERE sperson IN ( SELECT sperson FROM agentes WHERE cagente IN ( SELECT cpadre FROM redcomercial WHERE cagente IN (v_cagente)));
       EXCEPTION
         WHEN OTHERS THEN
         v_cpoblac := 1;
         v_cprovin := 11;
         v_cpostal := 11001;
       END;
       -- FIN - 08/09/2020 - Company - AR 37175 - Incidencias HU-EMI-PW-APGP-012

       BEGIN
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, '4600AQUI HACE EL INSERT POR DEFECTO A PER_DIRECCIONES NSPERSON = ' || NSPERSON, SQLERRM);
       Insert into PER_DIRECCIONES (SPERSON,CAGENTE,CDOMICI,CTIPDIR,CSIGLAS,TNOMVIA,NNUMVIA,TCOMPLE,TDOMICI,CPOSTAL,CPOBLAC,CPROVIN,CUSUARI,FMOVIMI,CVIAVP,CLITVP,CBISVP,CORVP,NVIAADCO,CLITCO,CORCO,NPLACACO,COR2CO,CDET1IA,TNUM1IA,CDET2IA,TNUM2IA,CDET3IA,TNUM3IA,IDDOMICI,LOCALIDAD,FDEFECTO,CMUNIC) 
       -- INICIO - 08/09/2020 - Company - AR 37175 - Incidencias HU-EMI-PW-APGP-012
       --values (NSPERSON,'17000','1','1',null,null,null,null,'.',null,'1','54','79962359',to_date('10/06/20','DD/MM/RR'),null,null,null,null,null,null,null,null,null,null,null,null,null,null,'.',null,null,null,null);
       values (NSPERSON,'17000','1','1',null,null,null,null,'NO REGISTRA DIRECCION',v_cpostal,v_cpoblac,v_cprovin,'AXIS',trunc(f_sysdate),null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
       -- FIN - 08/09/2020 - Company - AR 37175 - Incidencias HU-EMI-PW-APGP-012
       commit;
       EXCEPTION
          WHEN OTHERS THEN
           p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PER_DIRECCIONES ', SQLERRM);
       END;
       */
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '4639 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
      --37175 1. Asegurado no existe en la base de datos de iaxis y en el cargue masivo no trae ningún dato de contacto y dirección 
      -- Se inserta direccion del tomador en el asegurado
      IF cDireccion IS NULL THEN
        IF v_tdomici_t IS NOT NULL THEN

          BEGIN
            INSERT INTO PER_DIRECCIONES (SPERSON,CAGENTE,CDOMICI,CTIPDIR,CSIGLAS,TNOMVIA,NNUMVIA,TCOMPLE,TDOMICI,CPOSTAL,CPOBLAC,CPROVIN,CUSUARI,FMOVIMI,CVIAVP,CLITVP,CBISVP,CORVP,NVIAADCO,CLITCO,CORCO,NPLACACO,COR2CO,CDET1IA,TNUM1IA,CDET2IA,TNUM2IA,CDET3IA,TNUM3IA,IDDOMICI,LOCALIDAD,FDEFECTO,CMUNIC) 
            VALUES (NSPERSON,'17000',1,'1',null,null,null,null,v_tdomici_t,NULL,v_cpoblac_t,v_cprovin_t,'AXIS',trunc(f_sysdate),null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
            COMMIT;
          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PER_DIRECCIONES NSPERSON: ' || NSPERSON || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
          END;
        END IF;
      -- 37175 2.  Asegurado no existe en la base de datos de iaxis y en el cargue masivo trae los datos de contacto y dirección 
      -- se inserta la dirección que trae en el cargue
      ELSE

          BEGIN
            INSERT INTO PER_DIRECCIONES (SPERSON,CAGENTE,CDOMICI,CTIPDIR,CSIGLAS,TNOMVIA,NNUMVIA,TCOMPLE,TDOMICI,CPOSTAL,CPOBLAC,CPROVIN,CUSUARI,FMOVIMI,CVIAVP,CLITVP,CBISVP,CORVP,NVIAADCO,CLITCO,CORCO,NPLACACO,COR2CO,CDET1IA,TNUM1IA,CDET2IA,TNUM2IA,CDET3IA,TNUM3IA,IDDOMICI,LOCALIDAD,FDEFECTO,CMUNIC) 
            VALUES (NSPERSON,'17000',1,'1',null,null,null,null,cDireccion,null,cCiudad,cDepartamento,'AXIS',trunc(f_sysdate),null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
            COMMIT;
          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PER_DIRECCIONES NSPERSON: ' || NSPERSON || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
          END;
      END IF;

      --37175 1. Asegurado no existe en la base de datos de iaxis y en el cargue masivo no trae ningún dato de contacto y dirección 
      --  Se inserta telefono fijo del tomador en el asegurado
      IF cTelefono IS NULL THEN
        IF v_valcontel_t IS NOT NULL THEN

          BEGIN
            INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
            VALUES (NSPERSON,'17000',1,1,NULL,v_valcontel_t,'AXIS',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
          COMMIT;                   
          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS NSPERSON: ' || NSPERSON  || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
          END;
        END IF;
      -- 37175 2.  Asegurado no existe en la base de datos de iaxis y en el cargue masivo trae los datos de contacto y dirección 
      -- se inserta el telefono que trae en el cargue
      ELSE

        BEGIN
          INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
          VALUES (NSPERSON,'17000',1,1,NULL,cTelefono,'AXIS',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
        COMMIT;                   
        EXCEPTION
          WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS NSPERSON: ' || NSPERSON  || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
        END;
      END IF;
      --37175 1. Asegurado no existe en la base de datos de iaxis y en el cargue masivo no trae ningún dato de contacto y dirección 
      -- Se inserta el telefono movil del tomador en el asegurado
      IF cCelular IS NULL OR cCelular = 0 THEN
        IF v_valconcel_t IS NOT NULL THEN

          BEGIN
            INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
            VALUES (NSPERSON,'17000',2,6,NULL,v_valconcel_t,'AXIS',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
          COMMIT;                   
          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS NSPERSON: ' || NSPERSON  || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
          END;
        END IF;
      -- 37175 2.  Asegurado no existe en la base de datos de iaxis y en el cargue masivo trae los datos de contacto y dirección 
      -- se inserta el telefono movil que trae en el cargue
      ELSE

        BEGIN
          INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
          VALUES (NSPERSON,'17000',2,6,NULL,cCelular,'AXIS',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
        COMMIT;                   
        EXCEPTION
          WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS NSPERSON: ' || NSPERSON  || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
        END;
      END IF;
      --37175 1. Asegurado no existe en la base de datos de iaxis y en el cargue masivo no trae ningún dato de contacto y dirección 
      -- Se inserta el correo electronico del tomador en el asegurado
      IF cCorreoelectronico IS NULL THEN
        IF v_valconemail_t IS NOT NULL THEN

          BEGIN
            INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
            VALUES (NSPERSON,'17000',3,3,NULL,v_valconemail_t,'AXIS',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
          COMMIT;                   
          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS NSPERSON: ' || NSPERSON  || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
          END;
        END IF;
      ELSE

        BEGIN
          INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
          VALUES (NSPERSON,'17000',3,3,NULL,cCorreoelectronico,'AXIS',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
        COMMIT;                   
        EXCEPTION
          WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS NSPERSON: ' || NSPERSON  || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
        END;
      END IF;
      -- FIN - 24/03/2021 - Company - Ar 37175
------- daniel montenegro
         nExisteError := 0;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '4750 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
   -- INICIO -  29/08/2020 - Company - AR 37070 - Incidencias HU-EMI-PW-APGP-012
   ELSE  
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '4753 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
     -- INICIO - 24/03/2021 - Company - Ar 37175
     -- Se obtiene el SPERSON de la personaexistenr
     BEGIN
       SELECT max(SPERSON)
         INTO NSPERSON
         FROM PER_PERSONAS
        WHERE CTIPIDE = p_TIPO
          AND   NNUMIDE = p_NUMID;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         NSPERSON := NULL;
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PER_PERSONAS cObservaTrz = ' || cObservaTrz, SQLERRM);
     END;

      --37175 8. Asegurado existe en la base de datos de iaxis, tiene algunos datos de contacto y direccion  y el cargue no trae todos los datos contacto y direccion
      -- Se inserta direccion del tomador en el asegurado
      BEGIN
        SELECT cdomici, tdomici
        INTO v_cdomici_a, v_tdomici_a
        FROM per_direcciones
        WHERE sperson = NSPERSON
        AND cdomici = 1;
      EXCEPTION
        WHEN OTHERS THEN
          v_cdomici_a := NULL;
          v_tdomici_a := NULL;
          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PER_DIRECCIONES NSPERSON: ' || NSPERSON || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
      END;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '4782 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
      -- Si la direccion del asegurado ya existe entonces se actualiza con los datos que trae del cargue.
      IF cDireccion IS NOT NULL AND v_tdomici_a IS NOT NULL THEN

        BEGIN
          UPDATE per_direcciones 
             SET tdomici = cDireccion,
             cprovin = cDepartamento,
             cpoblac = cCiudad
           WHERE sperson = NSPERSON 
             AND cdomici = v_cdomici_a;
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION UPDATE PER_DIRECCIONES NSPERSON: ' || NSPERSON || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
        END;
      END IF;
      -- Si no viene direccion en el cargue y el asegurado existente no tiene direccion, inserta la direccion del tomador.
      IF cDireccion IS NULL THEN
         IF v_cdomici_a IS NULL THEN
           IF v_tdomici_t IS NOT NULL THEN

             BEGIN
               INSERT INTO PER_DIRECCIONES (SPERSON,CAGENTE,CDOMICI,CTIPDIR,CSIGLAS,TNOMVIA,NNUMVIA,TCOMPLE,TDOMICI,CPOSTAL,CPOBLAC,CPROVIN,CUSUARI,FMOVIMI,CVIAVP,CLITVP,CBISVP,CORVP,NVIAADCO,CLITCO,CORCO,NPLACACO,COR2CO,CDET1IA,TNUM1IA,CDET2IA,TNUM2IA,CDET3IA,TNUM3IA,IDDOMICI,LOCALIDAD,FDEFECTO,CMUNIC) 
               VALUES (NSPERSON,'17000',1,'1',null,null,null,null,v_tdomici_t,NULL,v_cpoblac_t,v_cprovin_t,'AXIS',trunc(f_sysdate),null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
             COMMIT;
             EXCEPTION
               WHEN OTHERS THEN
                 p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PER_DIRECCIONES NSPERSON: ' || NSPERSON || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
             END;
           END IF;
         END IF;
      END IF;

      -- Si el asegurado existe, tiene un telefono fijo de contacto y trae otro en el cargue, se agrega ese nuevo, si no tiene numero de contacto se agrega el del tomador
      BEGIN
        SELECT tvalcon
        INTO v_tvalcontel_a
        FROM PER_CONTACTOS
        WHERE SPERSON = NSPERSON
        AND ctipcon = 1
        AND cmodcon = (SELECT MAX(cmodcon) FROM per_contactos WHERE sperson = nsperson AND ctipcon= 1);
      EXCEPTION
        WHEN OTHERS THEN
          v_tvalcontel_a := NULL;
          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PER_CONTACTOS TELEFONO ASEGURADO NSPERSON: ' || NSPERSON || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
      END;

      -- Si el asegurado existe y se informa el telefono en el cargue se inserta en los contactos del asegurado
      IF cTelefono IS NOT NULL THEN
        BEGIN
          SELECT 1
          INTO v_existetel_a
          FROM PER_CONTACTOS
          WHERE sperson = NSPERSON
          AND tvalcon = cTelefono;
        EXCEPTION
          WHEN OTHERS THEN
            v_existetel_a := 0;
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PER_CONTACTOS EXISTE YA TELEFONO FIJO NSPERSON: ' || NSPERSON || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
        END;

        IF v_existetel_a <> 1 THEN
          BEGIN
            SELECT nvl(max(cmodcon),0) + 1
            INTO v_cmodconnext
            FROM PER_CONTACTOS
          WHERE SPERSON = NSPERSON;
          EXCEPTION
            WHEN OTHERS THEN
              v_cmodconnext := 1;
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PER_CONTACTOS CMODCON NSPERSON: ' || NSPERSON || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
          END;

          BEGIN
            INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
            VALUES (NSPERSON,'17000',v_cmodconnext,1,NULL,cTelefono,'AXIS',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
          COMMIT;                   
          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS NSPERSON: ' || NSPERSON  || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
          END;
        END IF;
      END IF;

      -- Si el asegurado existe y no se informa el telefono en el cargue se inserta el telefono del tomador
      IF cTelefono IS NULL AND v_tvalcontel_a IS NULL THEN
        BEGIN
          SELECT NVL(max(cmodcon),0) + 1
          INTO v_cmodconnext
          FROM PER_CONTACTOS
        WHERE SPERSON = NSPERSON;
        EXCEPTION
          WHEN OTHERS THEN
            v_cmodconnext := 1;
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PER_CONTACTOS CMODCON NSPERSON: ' || NSPERSON || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
        END;
        IF v_valcontel_t IS NOT NULL THEN

          BEGIN
            INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
            VALUES (NSPERSON,'17000',v_cmodconnext,1,NULL,v_valcontel_t,'AXIS',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
          COMMIT;                   
          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS NSPERSON: ' || NSPERSON  || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
          END;
        END IF;
      END IF;

      -- Si el asegurado existe, tiene un telefono movil de contacto y trae otro en el cargue, se agrega ese nuevo, si no tiene numero de contacto se agrega el del tomador
      BEGIN
        SELECT tvalcon
        INTO v_tvalconcel_a
        FROM PER_CONTACTOS
        WHERE SPERSON = NSPERSON
        AND ctipcon in (5,6)
        AND cmodcon = (SELECT MAX(cmodcon) FROM per_contactos WHERE sperson = nsperson AND ctipcon in (5,6));
      EXCEPTION
        WHEN OTHERS THEN
          v_tvalconcel_a := NULL;
          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PER_CONTACTOS TELEFONO MOVIL ASEGURADO NSPERSON: ' || NSPERSON || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
      END;

      -- Si el asegurado existe y se informa el telefono movil en el cargue se inserta en los contactos del asegurado
      IF cCelular IS NOT NULL AND cCelular <> '0' THEN
        BEGIN
          SELECT 1
          INTO v_existetel_a
          FROM PER_CONTACTOS
          WHERE sperson = NSPERSON
          AND tvalcon = cCelular;
        EXCEPTION
          WHEN OTHERS THEN
            v_existetel_a := 0;
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PER_CONTACTOS EXISTE YA TELEFONO MOVIL NSPERSON: ' || NSPERSON || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
        END;

        IF v_existetel_a <> 1 THEN
          BEGIN
            SELECT nvl(max(cmodcon),0) + 1
            INTO v_cmodconnext
            FROM PER_CONTACTOS
          WHERE SPERSON = NSPERSON;
          EXCEPTION
            WHEN OTHERS THEN
              v_cmodconnext := 1;
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PER_CONTACTOS CMODCON NSPERSON: ' || NSPERSON || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
          END;

          BEGIN
            INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
            VALUES (NSPERSON,'17000',v_cmodconnext,6,NULL,cCelular,'AXIS',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
          COMMIT;                   
          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS NSPERSON: ' || NSPERSON  || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
          END;
        END IF;
      END IF;

      -- Si el asegurado existe y no se informa el telefono movil en el cargue se inserta el telefono del tomador
      IF (cCelular IS NULL OR cCelular = '0') AND v_tvalconcel_a IS NULL THEN
        BEGIN
          SELECT nvl(max(cmodcon),0) + 1
          INTO v_cmodconnext
          FROM PER_CONTACTOS
        WHERE SPERSON = NSPERSON;
        EXCEPTION
          WHEN OTHERS THEN
            v_cmodconnext := 1;
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PER_CONTACTOS CMODCON NSPERSON: ' || NSPERSON || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
        END;
        IF v_valconcel_t IS NOT NULL THEN

          BEGIN
            INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
            VALUES (NSPERSON,'17000',v_cmodconnext,6,NULL,v_valconcel_t,'AXIS',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
          COMMIT;                   
          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS NSPERSON: ' || NSPERSON  || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
          END;
        END IF;
      END IF;

      -- Si el asegurado existe, tiene un correo electronico de contacto y trae otro en el cargue, se agrega ese nuevo, si no tiene correo electronico de contacto se agrega el del tomador
      BEGIN
        SELECT tvalcon
        INTO v_tvalconemail_a
        FROM PER_CONTACTOS
        WHERE SPERSON = NSPERSON
        AND ctipcon = 3
        AND cmodcon = (SELECT MAX(cmodcon) FROM per_contactos WHERE sperson = nsperson AND ctipcon = 3);
      EXCEPTION
        WHEN OTHERS THEN
          v_tvalconemail_a := NULL;
          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PER_CONTACTOS CORREO ELECTRONICO ASEGURADO NSPERSON: ' || NSPERSON || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
      END;

      -- Si el asegurado existe, no tiene correo y se informa el correo electronico en el cargue se inserta en los contactos del asegurado
      IF cCorreoelectronico IS NOT NULL THEN
        BEGIN
          SELECT 1
          INTO v_existemail_a
          FROM PER_CONTACTOS
          WHERE sperson = NSPERSON
          AND tvalcon = cCorreoelectronico;
        EXCEPTION
          WHEN OTHERS THEN
            v_existemail_a := 0;
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PER_CONTACTOS EXISTE YA CORREO ELECTRONICO NSPERSON: ' || NSPERSON || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
        END;

        IF v_existemail_a <> 1 THEN
          BEGIN
            SELECT nvl(max(cmodcon),0) + 1
            INTO v_cmodconnext
            FROM PER_CONTACTOS
          WHERE SPERSON = NSPERSON;
          EXCEPTION
            WHEN OTHERS THEN
              v_cmodconnext := 1;
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PER_CONTACTOS CMODCON NSPERSON: ' || NSPERSON || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
          END;

          BEGIN
            INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
            VALUES (NSPERSON,'17000',v_cmodconnext,3,NULL,cCorreoelectronico,'AXIS',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
          COMMIT;                   
          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS NSPERSON: ' || NSPERSON  || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
          END;
        END IF;
      END IF;

      -- Si el asegurado existe y no se informa el telefono movil en el cargue se inserta el telefono del tomador
      IF cCorreoelectronico IS NULL AND v_tvalconemail_a IS NULL THEN
        BEGIN
          SELECT nvl(max(cmodcon),0) + 1
          INTO v_cmodconnext
          FROM PER_CONTACTOS
        WHERE SPERSON = NSPERSON;
        EXCEPTION
          WHEN OTHERS THEN
            v_cmodconnext := 1;
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PER_CONTACTOS CMODCON NSPERSON: ' || NSPERSON || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
        END;
        IF v_valconemail_t IS NOT NULL THEN

          BEGIN
            INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
            VALUES (NSPERSON,'17000',v_cmodconnext,3,NULL,v_valconemail_t,'AXIS',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
          COMMIT;                   
          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS NSPERSON: ' || NSPERSON  || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
          END;
        END IF;
      END IF;
      -- FIN - 24/03/2021 - Company - Ar 37175

p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '5045 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
   --ELSIF nExistePer > 0 THEN
   -- FIN -  29/08/2020 - Company - AR 37070 - Incidencias HU-EMI-PW-APGP-012
   BEGIN
          SELECT MAX(SPERSON)
          INTO NSPERSON
          FROM PER_PERSONAS
          WHERE CTIPIDE = p_TIPO
          AND   NNUMIDE = p_NUMID;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             NSPERSON := NULL;
             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PER_PERSONAS ', SQLERRM);
        END;
   -- INICIO -  29/08/2020 - Company - AR 37070 - Incidencias HU-EMI-PW-APGP-012
   -- Valida si existen datos personales de la persona y los actualiza si estan nulos
     BEGIN
       SELECT csexper, fnacimi
       INTO v_Genero, v_FechaNacimiento
       FROM PER_PERSONAS
       WHERE sperson = NSPERSON;
     EXCEPTION
       WHEN OTHERS THEN
         NSPERSON := NULL;
         nExisteError := 1;
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PER_PERSONAS ', SQLERRM);
     END;
       IF v_Genero IS NULL THEN
         UPDATE per_personas set csexper = cGenero
         WHERE sperson = NSPERSON;
       END IF;
       IF v_FechaNacimiento IS NULL THEN
         UPDATE per_personas set fnacimi = cFechaNacimiento
         WHERE sperson = NSPERSON;
       END IF;
     BEGIN
       SELECT tapelli1, tapelli2, tnombre1, tnombre2
       INTO v_PrimerApellido, v_SegundoApellido, v_PrimerNombre, v_SegundoNombre
       FROM per_detper
       WHERE sperson = NSPERSON;
     EXCEPTION
       WHEN OTHERS THEN
         NSPERSON := NULL;
         nExisteError := 1;
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PER_DETPER ', SQLERRM);
     END;
       IF v_PrimerApellido IS NULL THEN
         UPDATE per_detper set tapelli1 = cPrimerApellido
         WHERE sperson = NSPERSON;
       END IF;
       IF v_SegundoApellido IS NULL THEN
         UPDATE per_detper set tapelli2 = cSegundoApellido
         WHERE sperson = NSPERSON;
       END IF;
       IF v_PrimerNombre IS NULL THEN
         UPDATE per_detper set tnombre1 = cPrimerNombre, tnombre = cPrimerNombre
         WHERE sperson = NSPERSON;
       END IF;
       IF v_SegundoNombre IS NULL THEN
         UPDATE per_detper set tnombre2 = cSegundoNombre
         WHERE sperson = NSPERSON;
       END IF;
   -- FIN -  29/08/2020 - Company - AR 37070 - Incidencias HU-EMI-PW-APGP-012*/
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '5109 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
   END IF;

       IF nExisteError <> 0 THEN
        cObservaTrz  := 'Consultar Datos de PER_PERSONAS No Existe: '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
       END IF;
         -- Insert  a asegurados
         nExisteError := 0;
         BEGIN
          SELECT COUNT(*)
          INTO nExisteAseg
          FROM ASEGURADOS A, SEGUROS S, PER_PERSONAS P
          WHERE A.SSEGURO = S.SSEGURO
          AND   S.NPOLIZA = pnpoliza
          AND   A.SPERSON = P.SPERSON          
          AND   P.CTIPIDE = p_TIPO
          AND   P.NNUMIDE = p_NUMID;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             nExisteAseg := 0;
             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT nExisteAseg ', SQLERRM);
        END;
         IF nExisteError <> 0 THEN
           cObservaTrz  := 'Consultar Datos de Asegurados No Existe: '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
         END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '5135 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
         IF NVL(nExisteAseg,0) = 0 AND NVL(nExistePer,0) = 0 THEN 
           nExisteError := 0;
--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB         
        ----- INICIO pedro yalltit
          BEGIN
            SELECT DISTINCT 1
            INTO  nExisteTomador
            FROM TOMADORES
            WHERE SPERSON = NSPERSON
            AND   SSEGURO = psseguro;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
               nExisteTomador := 0;
          END;
          ----- FIN pedro yalltit
          ----- INICIO pedro yalltit
          IF NVL(nExisteTomador,0) = 0 THEN
          ----- FIN pedro yalltit								 

          BEGIN
            INSERT INTO TOMADORES 
            (SPERSON,SSEGURO,NORDTOM,CDOMICI,CEXISTEPAGADOR,CTIPNOT) 
            values 
            (NSPERSON,psseguro,'1',1,'0','3'); 
            -- VALUES (psperson_promo, psseguro, 1, pcdomici_promo);

          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT TOMADORES ' ||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
            --   RETURN 110167;
         END;
         ----- INICIO pedro yalltit
         ELSE
           UPDATE TOMADORES
           SET CDOMICI = 1
           WHERE SPERSON = NSPERSON
            AND   SSEGURO = psseguro
            AND   CDOMICI IS NULL;
         END IF;
         ----- FIN pedro yalltit
         ----- INICIO pedro yalltit
          ----- INICIO pedro yalltit
          BEGIN
            SELECT DISTINCT 1
            INTO  nExisteDireccion
            FROM PER_DIRECCIONES
            WHERE SPERSON = NSPERSON;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
               nExisteDireccion := 0;
          END;
          ----- FIN pedro yalltit
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '5188 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
       IF NVL(nExisteDireccion,0) = 0 THEN

       BEGIN
         SELECT CAGENTE
         INTO CCAGENTE
         FROM PER_DETPER
         WHERE SPERSON = NSPERSON;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
            CCAGENTE := NULL;
       END;

       BEGIN
       Insert into PER_DIRECCIONES (SPERSON,CAGENTE,CDOMICI,CTIPDIR,CSIGLAS,TNOMVIA,NNUMVIA,TCOMPLE,TDOMICI,CPOSTAL,CPOBLAC,CPROVIN,CUSUARI,FMOVIMI,CVIAVP,CLITVP,CBISVP,CORVP,NVIAADCO,CLITCO,CORCO,NPLACACO,COR2CO,CDET1IA,TNUM1IA,CDET2IA,TNUM2IA,CDET3IA,TNUM3IA,IDDOMICI,LOCALIDAD,FDEFECTO,CMUNIC) 
       values (NSPERSON,NVL(CCAGENTE,'17000'),'1','1',null,null,null,null,'.',null,'1','54','79962359',to_date('10/06/20','DD/MM/RR'),null,null,null,null,null,null,null,null,null,null,null,null,null,null,'.',null,null,null,null);
       EXCEPTION
          WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PER_DIRECCIONES ' ||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
       END;

       -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
       -- El asegurado existe en iaxis pero ya tiene direccion de contacto se le actualiza la que ya tiene si:
       -- 'cDireccion, cDepartamento, cCiudad' no están nulos

         IF cDireccion IS NOT NULL THEN

           BEGIN
             UPDATE PER_DIRECCIONES
             SET TDOMICI = cDireccion
             WHERE SPERSON = NSPERSON
             AND CDOMICI = 1;
             --
             COMMIT;
             --
           EXCEPTION
             WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION UPDATE PER_DIRECCIONES SET TDOMICI nExistePer <>0' , SQLERRM);
           END;
         END IF;
         IF cDepartamento IS NOT NULL THEN

           BEGIN
             UPDATE PER_DIRECCIONES
             SET CPROVIN = cDepartamento
             WHERE SPERSON = NSPERSON
             AND CDOMICI = 1;
             --
             COMMIT;
             --
           EXCEPTION
             WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION UPDATE PER_DIRECCIONES SET CPROVIN nExistePer <>0' , SQLERRM);
           END;
         END IF;
         IF cCiudad IS NOT NULL THEN

           BEGIN
             UPDATE PER_DIRECCIONES
             SET CPOBLAC = cCiudad
             WHERE SPERSON = NSPERSON
             AND CDOMICI = 1;
             --
             COMMIT;
             --
           EXCEPTION
             WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION UPDATE PER_DIRECCIONES SET CPOBLAC nExistePer <>0' , SQLERRM);
           END;
         END IF;

       IF cTelefono IS NOT NULL THEN

         BEGIN
           SELECT nvl(MAX(cmodcon),0) + 1
           INTO v_cmodcon
           FROM per_contactos
           WHERE sperson = NSPERSON;
         EXCEPTION
           WHEN OTHERS THEN
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT MAX CMODCON FROM PER_CONTACTOS ' , SQLERRM);
         END;
         IF v_cmodcon IS NULL THEN
           v_cmodcon := 1;
         END IF;

         BEGIN

           INSERT INTO per_contactos (sperson,cagente,cmodcon,ctipcon,tcomcon,tvalcon,cusuari,fmovimi,cobliga,cdomici,cprefix) 
           VALUES (NSPERSON,NVL(CCAGENTE,'17000'),v_cmodcon,1,NULL,cTelefono,'AXIS',TO_DATE(f_sysdate, 'DD/MM/RR'),0,1,NULL);  
         COMMIT;
         EXCEPTION
           WHEN OTHERS THEN
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PER_CONTACTOS cTelefono SI nExistePer <>0 ' , SQLERRM);
         END;
       END IF;

       IF cCelular IS NOT NULL THEN

         BEGIN
           SELECT nvl(MAX(cmodcon),0) + 1
           INTO v_cmodcon
           FROM per_contactos
           WHERE sperson = NSPERSON;
         EXCEPTION
           WHEN OTHERS THEN
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT MAX CMODCON FROM PER_CONTACTOS ' , SQLERRM);
         END;
         IF v_cmodcon IS NULL THEN
           v_cmodcon := 1;
         END IF;

         BEGIN

           INSERT INTO per_contactos (sperson,cagente,cmodcon,ctipcon,tcomcon,tvalcon,cusuari,fmovimi,cobliga,cdomici,cprefix) 
           VALUES (NSPERSON,NVL(CCAGENTE,'17000'),v_cmodcon,1,NULL,cCelular,'AXIS',TO_DATE(f_sysdate, 'DD/MM/RR'),0,1,NULL);  
         COMMIT;
         EXCEPTION
           WHEN OTHERS THEN
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PER_CONTACTOS cCelular SI nExistePer <>0 ' , SQLERRM);
         END;
       END IF;
       -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
       -- INICIO - 24/03/2021 - Company - Ar 37175
       IF cCorreoelectronico IS NOT NULL THEN
         BEGIN
           SELECT nvl(MAX(cmodcon),0) + 1
           INTO v_cmodcon
           FROM per_contactos
           WHERE sperson = NSPERSON;
         EXCEPTION
           WHEN OTHERS THEN
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT MAX CMODCON FROM PER_CONTACTOS ' , SQLERRM);
         END;
         IF v_cmodcon IS NULL THEN
           v_cmodcon := 1;
         END IF;

         BEGIN

           INSERT INTO per_contactos (sperson,cagente,cmodcon,ctipcon,tcomcon,tvalcon,cusuari,fmovimi,cobliga,cdomici,cprefix) 
           VALUES (NSPERSON,NVL(CCAGENTE,'17000'),v_cmodcon,1,NULL,cCorreoelectronico,'AXIS',TO_DATE(f_sysdate, 'DD/MM/RR'),0,1,NULL);  
         COMMIT;
         EXCEPTION
           WHEN OTHERS THEN
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PER_CONTACTOS cCelular SI nExistePer <>0 ' , SQLERRM);
         END;
       END IF;
       -- FIN - 24/03/2021 - Company - Ar 37175
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '5337 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
       END IF;
       IF nExisteError = 0 THEN
        cObservaTrz  := 'Insert Datos de PER_DIRECCIONES: '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
       END IF;
       ----- FIN pedro yalltit
         BEGIN
            INSERT INTO asegurados
                        (sseguro, sperson, norden, cdomici, ffecini,nriesgo)
                 VALUES (psseguro, NSPERSON, 1, pcdomici_asseg, pfefecto,1);--STM : NRIESGO = P_NPLAN

         EXCEPTION
            WHEN OTHERS THEN

             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT ASEGURADOS ', SQLERRM);
            --   RETURN 110168;
          END;
         IF nExisteError = 0 THEN
            cObservaTrz  := 'Insert Datos de Asegurados(1): '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
         END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '5358 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
        ELSIF NVL(nExisteAseg,0) = 0 AND NVL(nExistePer,0) <> 0 THEN 
           BEGIN
            INSERT INTO asegurados
                        (sseguro, sperson, norden, cdomici, ffecini,nriesgo)
                 VALUES (psseguro, NSPERSON, 1, pcdomici_asseg, PAC_POS_CARGUE.dFechaIngreso,1);-- STM : NRIESGO = P_NPLAN
                 pfefecto := PAC_POS_CARGUE.dFechaIngreso;
                 PAC_POS_CARGUE.dFechaIngreso := NULL;

         EXCEPTION
            WHEN OTHERS THEN

             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT ASEGURADOS ', SQLERRM);
             -- RETURN 110168;
           END;
          ----- INICIO pedro yalltit
          BEGIN
            SELECT DISTINCT 1
            INTO  nExisteTomador
            FROM TOMADORES
            WHERE SPERSON = NSPERSON
            AND   SSEGURO = psseguro;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
               nExisteTomador := 0;
          END;
          ----- FIN pedro yalltit
          ----- INICIO pedro yalltit
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '5387 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
          IF NVL(nExisteTomador,0) = 0 THEN
          ----- FIN pedro yalltit							 
           BEGIN
            SELECT DISTINCT 1
            INTO  nExisteDireccion
            FROM PER_DIRECCIONES
            WHERE SPERSON = NSPERSON;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
               nExisteDireccion := 0;
          END;
          ----- FIN pedro yalltit
       IF NVL(nExisteDireccion,0) = 0 THEN
       -- INICIO - 08/09/2020 - Company - AR 37175 - Incidencias HU-EMI-PW-APGP-012
       BEGIN
         SELECT cagente
         INTO v_cagente
         FROM seguros
         WHERE npoliza = cPOLIZA
         AND ncertif = 0;
       EXCEPTION
         WHEN OTHERS THEN
           v_cagente:=17000;
       END;
       BEGIN
       SELECT cpoblac, cprovin, cpostal
         INTO v_cpoblac, v_cprovin, v_cpostal
         FROM per_direcciones
        WHERE sperson IN ( SELECT sperson FROM agentes WHERE cagente IN ( SELECT cpadre FROM redcomercial WHERE cagente IN (v_cagente)));
       EXCEPTION
         WHEN OTHERS THEN
         v_cpoblac := 1;
         v_cprovin := 11;
         v_cpostal := 11001;
       END;
       -- FIN - 08/09/2020 - Company - AR 37175 - Incidencias HU-EMI-PW-APGP-012
       -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
       -- El asegurado existe en iaxis pero no tiene direccion de contacto se le actualiza la que ya tiene si:
       -- 'cDireccion, cDepartamento, cCiudad' no están nulos
       -- cDepartamento corresponde a cprovin (ej 11) y cCiudad corresponde a cpoblac (ej 1)
       -- INT_CARGA_GENERICO campo20 = 1 departamento
       -- INT_CARGA_GENERICO campo21 = 11 ciudad

       IF cDireccion IS NOT NULL THEN
         IF cDepartamento IS NULL THEN
           cDepartamento := 11;
         END IF;

         IF cCiudad IS NULL THEN
           cCiudad := 1;
         END IF;

         IF v_cpostal IS NULL THEN
           v_cpostal := 11001;
         END IF;

         BEGIN
           SELECT 1
           INTO v_existcdom1
           FROM per_direcciones
           WHERE sperson = NSPERSON
           AND CDOMICI = 1;
         EXCEPTION
           WHEN OTHERS THEN
             v_existcdom1 := 0;
         END;

         IF NVL(v_existcdom1,0) = 0 THEN

           BEGIN
             INSERT INTO PER_DIRECCIONES (SPERSON,CAGENTE,CDOMICI,CTIPDIR,CSIGLAS,TNOMVIA,NNUMVIA,TCOMPLE,TDOMICI,CPOSTAL,CPOBLAC,CPROVIN,CUSUARI,FMOVIMI,CVIAVP,CLITVP,CBISVP,CORVP,NVIAADCO,CLITCO,CORCO,NPLACACO,COR2CO,CDET1IA,TNUM1IA,CDET2IA,TNUM2IA,CDET3IA,TNUM3IA,IDDOMICI,LOCALIDAD,FDEFECTO,CMUNIC) 
             VALUES (NSPERSON,'17000','1','1',null,null,null,null,cDireccion,v_cpostal,cCiudad,cDepartamento,'AXIS',trunc(f_sysdate),null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);

           COMMIT;
           EXCEPTION
             WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PER_DIRECCIONES EXISTE EN CARGUE Y EN IAXIS NO', SQLERRM);
           END;
         ELSE
         BEGIN
           UPDATE PER_DIRECCIONES
              SET TDOMICI = cDireccion
            WHERE SPERSON = NSPERSON
             AND CDOMICI = 1;
             --
             COMMIT;
             --
         EXCEPTION
           WHEN OTHERS THEN
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION UPDATE PER_DIRECCIONES SET TDOMICI nExistePer <>0' , SQLERRM);
         END;
         END IF;
       -- Se inserta por defecto en la direccion del asegurado: NO REGISTRA DIRECCION
       ELSE
       -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
       -- INICIO - 24/03/2021 - Company - Ar 37175
       /*
       BEGIN

       Insert into PER_DIRECCIONES (SPERSON,CAGENTE,CDOMICI,CTIPDIR,CSIGLAS,TNOMVIA,NNUMVIA,TCOMPLE,TDOMICI,CPOSTAL,CPOBLAC,CPROVIN,CUSUARI,FMOVIMI,CVIAVP,CLITVP,CBISVP,CORVP,NVIAADCO,CLITCO,CORCO,NPLACACO,COR2CO,CDET1IA,TNUM1IA,CDET2IA,TNUM2IA,CDET3IA,TNUM3IA,IDDOMICI,LOCALIDAD,FDEFECTO,CMUNIC) 
       -- INICIO - 08/09/2020 - Company - AR 37175 - Incidencias HU-EMI-PW-APGP-012
       --values (NSPERSON,'17000','1','1',null,null,null,null,'.',null,'1','54','79962359',to_date('10/06/20','DD/MM/RR'),null,null,null,null,null,null,null,null,null,null,null,null,null,null,'.',null,null,null,null);
       values (NSPERSON,'17000','1','1',null,null,null,null,'NO REGISTRA DIRECCION',v_cpostal,v_cpoblac,v_cprovin,'AXIS',trunc(f_sysdate),null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
       -- FIN - 08/09/2020 - Company - AR 37175 - Incidencias HU-EMI-PW-APGP-012
       commit;
       EXCEPTION
          WHEN OTHERS THEN
            BEGIN

              UPDATE PER_DIRECCIONES SET CDOMICI = 'NO REGISTRA DIRECCION', cpostal = '11001', cpoblac = 1, cprovin = 11
              WHERE SPERSON = NSPERSON
              AND cdomici = 1
              AND CTIPDIR = 1;
              COMMIT;
            EXCEPTION
              WHEN OTHERS THEN
                nExisteError := 1;
                nSqlerrm     := Sqlerrm;
                nSqlCode     := SqlCode;
                cObservaTrz  := 'Insert Datos de PER_DIRECCIONES: Error '||nSqlCode||' '||nSqlerrm;
                p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PER_DIRECCIONES cObservaTrz = ' || cObservaTrz, SQLERRM);
            END;
       END;
       */
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '5513 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
      --37175 1. Asegurado no existe en la base de datos de iaxis y en el cargue masivo no trae ningún dato de contacto y dirección 
      -- Se inserta direccion del tomador en el asegurado
      IF cDireccion IS NULL THEN
        IF v_tdomici_t IS NOT NULL THEN

          BEGIN
            INSERT INTO PER_DIRECCIONES (SPERSON,CAGENTE,CDOMICI,CTIPDIR,CSIGLAS,TNOMVIA,NNUMVIA,TCOMPLE,TDOMICI,CPOSTAL,CPOBLAC,CPROVIN,CUSUARI,FMOVIMI,CVIAVP,CLITVP,CBISVP,CORVP,NVIAADCO,CLITCO,CORCO,NPLACACO,COR2CO,CDET1IA,TNUM1IA,CDET2IA,TNUM2IA,CDET3IA,TNUM3IA,IDDOMICI,LOCALIDAD,FDEFECTO,CMUNIC) 
            VALUES (NSPERSON,'17000',1,'1',null,null,null,null,v_tdomici_t,v_cpostal,v_cpoblac_t,v_cprovin_t,'AXIS',trunc(f_sysdate),null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
            COMMIT;
          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PER_DIRECCIONES NSPERSON: ' || NSPERSON || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
          END;
        END IF;
      -- 37175 2.  Asegurado no existe en la base de datos de iaxis y en el cargue masivo trae los datos de contacto y dirección 
      -- se inserta la dirección que trae en el cargue
      ELSE

          BEGIN
            INSERT INTO PER_DIRECCIONES (SPERSON,CAGENTE,CDOMICI,CTIPDIR,CSIGLAS,TNOMVIA,NNUMVIA,TCOMPLE,TDOMICI,CPOSTAL,CPOBLAC,CPROVIN,CUSUARI,FMOVIMI,CVIAVP,CLITVP,CBISVP,CORVP,NVIAADCO,CLITCO,CORCO,NPLACACO,COR2CO,CDET1IA,TNUM1IA,CDET2IA,TNUM2IA,CDET3IA,TNUM3IA,IDDOMICI,LOCALIDAD,FDEFECTO,CMUNIC) 
            VALUES (NSPERSON,'17000',1,'1',null,null,null,null,cDireccion,null,cCiudad,cDepartamento,'AXIS',trunc(f_sysdate),null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
            COMMIT;
          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PER_DIRECCIONES NSPERSON: ' || NSPERSON || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
          END;
      END IF;
      --37175 1. Asegurado no existe en la base de datos de iaxis y en el cargue masivo no trae ningún dato de contacto y dirección 
      --  Se inserta telefono fijo del tomador en el asegurado
      IF cTelefono IS NULL THEN
        IF v_valcontel_t IS NOT NULL THEN

          BEGIN
            INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
            VALUES (NSPERSON,'17000',1,1,NULL,v_valcontel_t,'AXIS',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
          COMMIT;                   
          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS NSPERSON: ' || NSPERSON  || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
          END;
        END IF;
      -- 37175 2.  Asegurado no existe en la base de datos de iaxis y en el cargue masivo trae los datos de contacto y dirección 
      -- se inserta el telefono que trae en el cargue
      ELSE

        BEGIN
          INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
          VALUES (NSPERSON,'17000',1,1,NULL,cTelefono,'AXIS',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
        COMMIT;                   
        EXCEPTION
          WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS NSPERSON: ' || NSPERSON  || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
        END;
      END IF;
      --37175 1. Asegurado no existe en la base de datos de iaxis y en el cargue masivo no trae ningún dato de contacto y dirección 
      -- Se inserta el telefono movil del tomador en el asegurado
      IF cCelular IS NULL OR cCelular = 0 THEN
        IF v_valconcel_t IS NOT NULL THEN

          BEGIN
            INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
            VALUES (NSPERSON,'17000',3,6,NULL,v_valconcel_t,'AXIS',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
          COMMIT;                   
          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS NSPERSON: ' || NSPERSON  || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
          END;
        END IF;
      -- 37175 2.  Asegurado no existe en la base de datos de iaxis y en el cargue masivo trae los datos de contacto y dirección 
      -- se inserta el telefono movil que trae en el cargue
      ELSE

        BEGIN
          INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
          VALUES (NSPERSON,'17000',3,6,NULL,cCelular,'AXIS',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
        COMMIT;                   
        EXCEPTION
          WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS NSPERSON: ' || NSPERSON  || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
        END;
      END IF;
      --37175 1. Asegurado no existe en la base de datos de iaxis y en el cargue masivo no trae ningún dato de contacto y dirección 
      -- Se inserta el correo electronico del tomador en el asegurado
      IF cCorreoelectronico IS NULL THEN
        IF v_valconemail_t IS NOT NULL THEN

          BEGIN
            INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
            VALUES (NSPERSON,'17000',4,3,NULL,v_valconemail_t,'AXIS',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
          COMMIT;                   
          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS NSPERSON: ' || NSPERSON  || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
          END;
        END IF;
      ELSE

        BEGIN
          INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
          VALUES (NSPERSON,'17000',4,3,NULL,cCorreoelectronico,'AXIS',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
        COMMIT;                   
        EXCEPTION
          WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS NSPERSON: ' || NSPERSON  || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
        END;
      END IF;
      -- FIN - 24/03/2021 - Company - Ar 37175

       -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
       END IF;
       -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '5625 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
       END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '5627 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
       BEGIN
           SELECT MAX(CDOMICI)
           INTO v_cdomici
           FROM PER_DIRECCIONES
           WHERE SPERSON = NSPERSON;
        EXCEPTION
           WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PER_DIRECCIONES ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
       END;
       ----- FIN pedro yalltit
         BEGIN
            INSERT INTO TOMADORES 
            (SPERSON,SSEGURO,NORDTOM,CDOMICI,CEXISTEPAGADOR,CTIPNOT) 
            values 
            (NSPERSON,psseguro,'1',NVL(v_cdomici,1),'0','3');     
                -- VALUES (psperson_promo, psseguro, 1, pcdomici_promo);
         EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT TOMADORES EXISTENTE  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
            --   RETURN 110167;
         END;
       ----- INICIO pedro yalltit
         ELSE
           UPDATE TOMADORES
           SET CDOMICI = 1
           WHERE SPERSON = NSPERSON
            AND   SSEGURO = psseguro
            AND   CDOMICI IS NULL;
         END IF;
         ----- FIN pedro yalltit
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '5657 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
        END IF;
--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB        
         nExisteError := 0;
         IF NVL(nExisteAseg,0) <> 0 THEN 
          BEGIN
          SELECT DISTINCT A.SSEGURO
          INTO  PSSEGUROASEG
          FROM ASEGURADOS A, SEGUROS S, PER_PERSONAS P
          WHERE A.SSEGURO = S.SSEGURO
          AND   S.NPOLIZA = pnpoliza
          AND   A.SPERSON = P.SPERSON          
          AND   P.CTIPIDE = p_TIPO
          AND   P.NNUMIDE = p_NUMID;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             PSSEGUROASEG := NULL;
             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT ASEGURADOS SEGUROS PER_PERSONAS', SQLERRM);
        END;
        END IF;
         -- Insertem els aportants
         nExisteError := 0;
         -- Insertem a riesgos
         IF NVL(nExisteAseg,0) =  0 THEN 
--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB    
           BEGIN
             SELECT sperson
             INTO v_sperson
             FROM per_personas
             where ctipide = p_TIPO
             and nnumide = p_NUMID;
           EXCEPTION
             WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT SPERSON ANTES DEL INSERT INTO RIESGOS', SQLERRM);
           END;

         BEGIN
         INSERT INTO riesgos
                        (nriesgo, sseguro, nmovima, fefecto, sperson, cclarie, nmovimb,
                         fanulac, tnatrie, cdomici, nasegur, cactivi)
                         --fanulac, tnatrie, cdomici, nasegur, nedacol, csexcol, sbonush, 
                         --czbonus, ctipdiraut, spermin, cactivi, cmodalidad,pdtocom,precarg,
                         --pdtotec, preccom)
             (SELECT '1', psseguro, '1', R.fefecto, null, R.cclarie, R.nmovimb,
             R.fanulac, R.tnatrie, R.cdomici, R.nasegur, R.cactivi
            --(SELECT '1', psseguro, '1', R.fefecto, v_sperson, null, null,
            --null,null,null,null,null,null,null,
            --null,null,null,null,null,0,0,
            --0,0
             FROM riesgos R, SEGUROS S
             WHERE R.SSEGURO = S.SSEGURO
             AND   S.NCERTIF = 0
             AND   S.NPOLIZA = pnpoliza
             AND   R.nriesgo = P_NPLAN);--STM : NRIESGO = P_NPLAN
             EXCEPTION
               WHEN OTHERS THEN
                     nExisteError := 1;
                     p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT RIESGOS', SQLERRM);
             END;    
--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB
         IF nExisteError = 0 THEN
            cObservaTrz  := 'Insert Datos de riesgos: '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
         END IF;
         END IF;
         --- INICIO PYALLTIT  06062020
         ---- preguntas 4315 cCodigo
         BEGIN
         INSERT INTO PREGUNSEG (SSEGURO, NRIESGO,CPREGUN,CRESPUE,NMOVIMI,TRESPUE)
         VALUES(psseguro, 1,4315,NULL,1,cCodigo);
         EXCEPTION
           WHEN OTHERS THEN
                     nExisteError := 1;
                     p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PREGUNSEG ', SQLERRM);
           END; 
         IF nExisteError = 0 THEN
            cObservaTrz  := 'Insert Datos de PREGUNSEG(4315): '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
         END IF;
        ---- preguntas 4316 cCursoSede
        nExisteError := 0;
        BEGIN
            INSERT INTO PREGUNSEG (SSEGURO, NRIESGO,CPREGUN,CRESPUE,NMOVIMI,TRESPUE)
            VALUES(psseguro, 1,4316,NULL,1,cCursoSede);
        EXCEPTION
         WHEN OTHERS THEN
                     nExisteError := 1;
                     p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PREGUNSEG 2 ', SQLERRM);
           END; 
         IF nExisteError = 0 THEN
            cObservaTrz  := 'Insert Datos de PREGUNSEG(4316): '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
         END IF; 
         --- FIN PYALLTIT  06062020
         nExisteError := 0;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '5735 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
         IF NVL(nExisteAseg,0) =  0 THEN
           BEGIN
             INSERT INTO claususeg(sseguro, nmovimi, sclagen, finiclau, ffinclau)
             (SELECT psseguro, NVL(lnmovimi,1), C.sclagen, C.finiclau, C.ffinclau
              FROM claususeg C, SEGUROS S
              WHERE C.SSEGURO = S.SSEGURO
              AND   S.NCERTIF = 0 
              AND   C.nmovimi = (SELECT MAX(C2.nmovimi)  FROM claubenseg C2 WHERE C2.SSEGURO = C.SSEGURO)
              AND   S.NPOLIZA = pnpoliza);
           EXCEPTION
            WHEN OTHERS THEN
             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT CLAUSUSEG ', SQLERRM);
           END;
           IF nExisteError = 0 THEN
            cObservaTrz  := 'Insert Datos de claususeg(1): '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
           END IF;
         ELSIF NVL(nExisteAseg,0) <> 0 THEN
            BEGIN
             INSERT INTO claususeg(sseguro, nmovimi, sclagen, finiclau, ffinclau)
             (SELECT psseguro, NVL(C.nmovimi,0) + 1, C.sclagen, C.finiclau, C.ffinclau
              FROM claususeg C, SEGUROS S
              WHERE C.SSEGURO = S.SSEGURO
              AND   S.NPOLIZA = pnpoliza
              AND   C.nmovimi = (SELECT MAX(C2.nmovimi)  FROM claususeg C2 WHERE C2.SSEGURO = C.SSEGURO)
              AND   C.SSEGURO = PSSEGUROASEG);  
            EXCEPTION
            WHEN OTHERS THEN
             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT CLAUSUSEG 2 ', SQLERRM);
           END;
           IF nExisteError = 0 THEN
            cObservaTrz  := 'Insert Datos de claususeg(2): '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
           END IF;
         END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '5771 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
           -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
           FOR x in (SELECT r.sperson,r.nmovimi,r.pretorno,r.idconvenio
             FROM rtn_convenio r,seguros s
             WHERE r.sseguro = s.sseguro
             AND r.nmovimi = (SELECT MAX(nmovimi) FROM rtn_convenio WHERE sseguro = (select sseguro from seguros where npoliza = pnpoliza and ncertif = 0))
             AND s.npoliza = pnpoliza
             AND s.ncertif = 0) LOOP
             BEGIN
               INSERT INTO RTN_CONVENIO (SSEGURO,SPERSON,NMOVIMI,PRETORNO,IDCONVENIO)
               VALUES(psseguro, x.sperson, x.nmovimi, x.pretorno, x.idconvenio);
               COMMIT;
             EXCEPTION
               WHEN OTHERS THEN
                 p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT RTN_CONVENIO', SQLERRM);
             END;
           END LOOP;
           -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '5789 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
        --  VALUES (psseguro, lnmovimi, vcla.sclagen, pfefecto, NULL);
         -- Insertem beneficiaris
         nExisteError := 0;
         IF NVL(nExisteAseg,0) =  0 THEN
           BEGIN
             INSERT INTO claubenseg(finiclau, sclaben, sseguro, nriesgo, nmovimi)
             (SELECT C.finiclau, C.sclaben, psseguro, nriesgo, lnmovimi
              FROM claubenseg C, SEGUROS S
              WHERE C.SSEGURO = S.SSEGURO
              AND   S.NCERTIF = 0 
              AND   C.nmovimi = (SELECT MAX(C2.nmovimi)  FROM claubenseg C2 WHERE C2.SSEGURO = C.SSEGURO)
              AND   S.NPOLIZA = pnpoliza);
            EXCEPTION
            WHEN OTHERS THEN
             nExisteError := 1;
             nSqlerrm     := Sqlerrm;
             nSqlCode     := SqlCode;
             cObservaTrz  := 'Insert Datos de claubenseg(1): Error '||nSqlCode||' '||nSqlerrm||' '||cObservaTrz;
           END;
           IF nExisteError = 0 THEN
            cObservaTrz  := 'Insert Datos de claubenseg(1): '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
           END IF;
         ELSIF NVL(nExisteAseg,0) <> 0 THEN
           BEGIN
             INSERT INTO claubenseg(finiclau, sclaben, sseguro, nriesgo, nmovimi)
             (SELECT C.finiclau, C.sclaben, psseguro, nriesgo, NVL(C.nmovimi,0) + 1
              FROM claubenseg C, SEGUROS S
              WHERE C.SSEGURO = S.SSEGURO
              AND   S.NPOLIZA = pnpoliza
              AND   C.nmovimi = (SELECT MAX(C2.nmovimi)  FROM claubenseg C2 WHERE C2.SSEGURO = C.SSEGURO)
              AND   C.SSEGURO = PSSEGUROASEG);
          EXCEPTION
            WHEN OTHERS THEN
             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT claubenseg ', SQLERRM);
           END;
           IF nExisteError = 0 THEN
            cObservaTrz  := 'Insert Datos de claubenseg(2): '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
           END IF;
         END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '5830 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
          -- Insertem beneficiaris
         lnordcla := 1;
         nExisteError := 0;
         IF NVL(nExisteAseg,0) =  0 THEN
--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB         
         BEGIN
             INSERT INTO clausuesp(nmovimi, sseguro, cclaesp, nordcla, nriesgo, finiclau, sclagen,
                            tclaesp, ffinclau)
             (SELECT NVL(lnmovimi,1), psseguro, C.cclaesp, C.nordcla, C.nriesgo, C.finiclau, C.sclagen,C.tclaesp, C.ffinclau
              FROM clausuesp C, SEGUROS S
              WHERE C.SSEGURO = S.SSEGURO
              AND   S.NCERTIF = 0 
              AND   C.nmovimi = (SELECT MAX(C2.nmovimi)  FROM clausuesp C2 WHERE C2.SSEGURO = C.SSEGURO)
              AND   S.NPOLIZA = pnpoliza
              AND   C.nriesgo = 1);--STM : NRIESGO = P_NPLAN
         EXCEPTION
            WHEN OTHERS THEN
             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT CLAUSUESP ', SQLERRM);
          END; 
--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB         
           IF nExisteError = 0 THEN
            cObservaTrz  := 'Insert Datos de clausuesp(1): '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
           END IF;
         ELSIF NVL(nExisteAseg,0) <> 0 THEN
--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB         
           BEGIN
             INSERT INTO clausuesp(nmovimi, sseguro, cclaesp, nordcla, nriesgo, finiclau, sclagen,
                            tclaesp, ffinclau)
             (SELECT NVL(C.nmovimi,0) + 1, psseguro, C.cclaesp, C.nordcla, C.nriesgo, C.finiclau, C.sclagen ,C.tclaesp, C.ffinclau
              FROM clausuesp C, SEGUROS S
              WHERE C.SSEGURO = S.SSEGURO
              AND   S.NPOLIZA = pnpoliza
              AND   C.nmovimi = (SELECT MAX(C2.nmovimi)  FROM clausuesp C2 WHERE C2.SSEGURO = C.SSEGURO)
              AND   C.SSEGURO = PSSEGUROASEG
              AND   C.nriesgo = 1);--STM : NRIESGO = P_NPLAN
          EXCEPTION
            WHEN OTHERS THEN
             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT CLAUSUESP 2 ', SQLERRM);
          END; 
--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB          
           IF nExisteError = 0 THEN
            cObservaTrz  := 'Insert Datos de clausuesp(2): '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
           END IF;
         END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '5877 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
      nExisteError := 0;
     IF NVL(nExisteAseg,0) =  0 THEN   
--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB     
      BEGIN
         INSERT INTO PREGUNSEG(SSEGURO,         NRIESGO,    CPREGUN,    CRESPUE,NMOVIMI,   TRESPUE)
         (SELECT psseguro, '1',    P.CPREGUN,    P.CRESPUE, '1',   P.TRESPUE
         FROM PREGUNSEG P, SEGUROS S
         WHERE P.SSEGURO = S.SSEGURO
         AND   S.NCERTIF = 0
         AND   P.nmovimi = (SELECT MAX(C2.nmovimi)  FROM PREGUNSEG C2 WHERE C2.SSEGURO = P.SSEGURO) 
         AND   S.NPOLIZA = pnpoliza
         AND   P.NRIESGO = P_NPLAN);--STM p: NRIESGO = P_NPLAN
     EXCEPTION
       WHEN OTHERS THEN
             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PREGUNSEG ', SQLERRM);
      END;
--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB    
      IF nExisteError = 0 THEN
        cObservaTrz  := 'Insert Datos de PREGUNSEG(1): '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
      END IF;
   ELSIF NVL(nExisteAseg,0) <>  0 THEN
--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB   
          BEGIN
         INSERT INTO pregungaranseg(SSEGURO,         NRIESGO,    CPREGUN,    CRESPUE,NMOVIMI,   TRESPUE)
         (SELECT P.SSEGURO,         P.NRIESGO,    P.CPREGUN,    P.CRESPUE, NVL(P.NMOVIMI,0) + 1,   P.TRESPUE
         FROM PREGUNSEG P, SEGUROS S
         WHERE P.SSEGURO = S.SSEGURO
         AND   S.SSEGURO = PSSEGUROASEG
         AND   P.nmovimi = (SELECT MAX(C2.nmovimi)  FROM PREGUNSEG C2 WHERE C2.SSEGURO = P.SSEGURO) 
         AND   S.NPOLIZA = pnpoliza
         AND   P.NRIESGO = P_NPLAN);--STM : NRIESGO = P_NPLAN
     EXCEPTION
       WHEN OTHERS THEN
             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PREGUNGARANSEG ', SQLERRM);
    END;
--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB    
      IF nExisteError = 0 THEN
        cObservaTrz  := 'Insert Datos de PREGUNSEG(2): '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
      END IF;
    END IF;
     nExisteError := 0;
     IF NVL(nExisteAseg,0) =  0 THEN  
--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB     
    BEGIN
         INSERT INTO pregunpolseg(SSEGURO,            CPREGUN,    CRESPUE,NMOVIMI,   TRESPUE)
         (SELECT psseguro,          P.CPREGUN,    P.CRESPUE, lnmovimi,   P.TRESPUE
         FROM pregunpolseg P, SEGUROS S
         WHERE P.SSEGURO = S.SSEGURO
         AND   S.NCERTIF = 0
         AND   P.nmovimi = (SELECT MAX(C2.nmovimi)  FROM pregunpolseg C2 WHERE C2.SSEGURO = P.SSEGURO) 
         AND   S.NPOLIZA = pnpoliza);
     EXCEPTION
       WHEN OTHERS THEN
             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PREGUNPOLSEG ', SQLERRM);
     END;    
      BEGIN
         INSERT INTO PREGUNPOLSEG(SSEGURO, CPREGUN, CRESPUE, NMOVIMI, TRESPUE)
         values (psseguro,'4089',P_NPLAN,'1',null);
       EXCEPTION
       WHEN OTHERS THEN
             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PREGUNPOLSEG 2 ', SQLERRM);
    END;
  --  END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '5945 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB    
       IF nExisteError = 0 THEN
        cObservaTrz  := 'Insert Datos de pregunpolseg(1): '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
      END IF;
   ELSIF NVL(nExisteAseg,0) <>  0 THEN
       BEGIN
         INSERT INTO pregunpolseg(SSEGURO,            CPREGUN,    CRESPUE,NMOVIMI,   TRESPUE)
         (SELECT P.SSEGURO,           P.CPREGUN,    P.CRESPUE, NVL(P.NMOVIMI,0) + 1,   P.TRESPUE
         FROM pregunpolseg P, SEGUROS S
         WHERE P.SSEGURO = S.SSEGURO
         AND   S.SSEGURO = PSSEGUROASEG
         AND   P.nmovimi = (SELECT MAX(C2.nmovimi)  FROM pregunpolseg C2 WHERE C2.SSEGURO = P.SSEGURO) 
         AND   S.NPOLIZA = pnpoliza);
     EXCEPTION
       WHEN OTHERS THEN
             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PREGUNPOLSEG 3 ', SQLERRM);
    END;
      IF nExisteError = 0 THEN
        cObservaTrz  := 'Insert Datos de pregunpolseg(2): '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
      END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '5967 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
    END IF;
   nExisteError := 0;
  IF NVL(nExisteAseg,0) =  0 THEN   
--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB   
      BEGIN
         INSERT INTO pregungaranseg(SSEGURO,        NRIESGO,     CGARANT,NMOVIMI,CPREGUN,CRESPUE,  NMOVIMA,  FINIEFE,     TRESPUE)
         (SELECT psseguro,        NRIESGO,     CGARANT,lnmovimi,CPREGUN,CRESPUE,  NMOVIMA,  FINIEFE,     TRESPUE
         FROM pregungaranseg P, SEGUROS S
         WHERE P.SSEGURO = S.SSEGURO
         AND   S.NCERTIF = 0
         AND   P.nmovimi = (SELECT MAX(C2.nmovimi)  FROM pregungaranseg C2 WHERE C2.SSEGURO = P.SSEGURO) 
         AND   S.NPOLIZA = pnpoliza
         AND   P.NRIESGO = P_NPLAN);--STM : NRIESGO = P_NPLAN
     EXCEPTION
       WHEN OTHERS THEN
             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PREGUNGARANSEG ', SQLERRM);
    END;
--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB    
      IF nExisteError = 0 THEN
        cObservaTrz  := 'Insert Datos de pregungaranseg(1): '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
      END IF;
 ELSIF NVL(nExisteAseg,0) <>  0 THEN
--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB   
       BEGIN
         INSERT INTO pregungaranseg(SSEGURO,        NRIESGO,     CGARANT,NMOVIMI,CPREGUN,CRESPUE,  NMOVIMA,  FINIEFE,     TRESPUE)
         (SELECT psseguro,        NRIESGO,     CGARANT,NVL(NMOVIMI,0) + 1,CPREGUN,CRESPUE,  NMOVIMA,  FINIEFE,     TRESPUE
         FROM pregungaranseg P, SEGUROS S
         WHERE P.SSEGURO = S.SSEGURO
         AND   S.SSEGURO = PSSEGUROASEG
         AND   P.nmovimi = (SELECT MAX(C2.nmovimi)  FROM pregungaranseg C2 WHERE C2.SSEGURO = P.SSEGURO) 
         AND   S.NPOLIZA = pnpoliza
         AND   P.NRIESGO = P_NPLAN);--STM : NRIESGO = P_NPLAN
     EXCEPTION
       WHEN OTHERS THEN
             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PREGUNGARANSEG ', SQLERRM);
      END;
--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB    
      IF nExisteError = 0 THEN
        cObservaTrz  := 'Insert Datos de pregungaranseg(2): '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
      END IF;
    END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '6011 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
           -- INICIO -  27/08/2020 - Company - AR 37035 - Incidencias HU-EMI-APGP-017
           -- Se obtiene la respuesta pregunta 9831 (Tipo de calculo de prima)
           BEGIN
             SELECT crespue
             INTO v_crespue
             FROM pregunpolseg
             WHERE cpregun = 9831
             AND sseguro = (SELECT sseguro FROM seguros WHERE npoliza = pnpoliza AND ncertif = 0)
             AND nmovimi = (SELECT MAX(nmovimi) FROM axis.pregunpolseg WHERE sseguro = (SELECT sseguro FROM axis.seguros WHERE npoliza = pnpoliza AND ncertif = 0));
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
               NULL;
             WHEN OTHERS THEN
               nExisteError := 1;
               p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT PREGUNPOLSEG ', SQLERRM);
           END;
           -- FIN -  27/08/2020 - Company - AR 37035 - Incidencias HU-EMI-APGP-017
         nExisteError := 0;                  
         IF NVL(nExisteAseg,0) =  0 THEN 
           -- INICIO - 11/09/2020 - Company - AR 37166 - Incidencias HU-EMI-APGP-004 
           -- INICIO -  27/08/2020 - Company - AR 37035 - Incidencias HU-EMI-APGP-017
           -- Si es prima por presupuesto no debe calcular prima
           /*IF v_crespue = 2 THEN
             BEGIN
               INSERT INTO garanseg(cgarant, nriesgo, nmovimi, sseguro, finiefe, norden,
                                    ctarifa, icapital, icaptot, iprianu, ipritar, ipritot, ftarifa,crevali)
              (SELECT G.cgarant, G.nriesgo, NVL(G.nmovimi,0) + 1, psseguro, G.finiefe, G.norden,G.ctarifa,G.icapital, G.icaptot, 
               0,0,0,G.ftarifa,G.crevali
               FROM garanseg G, SEGUROS S
               WHERE G.SSEGURO = S.SSEGURO
               AND   G.nmovimi = (SELECT MAX(C2.nmovimi)  FROM garanseg C2 WHERE C2.SSEGURO = G.SSEGURO) 
               AND   S.NPOLIZA = pnpoliza
               AND   G.SSEGURO = PSSEGUROASEG
               AND   G.NRIESGO = P_NPLAN);--STM r : NRIESGO = P_NPLAN
            EXCEPTION
              WHEN OTHERS THEN
               nExisteError := 1;
               nSqlerrm     := Sqlerrm;
               nSqlCode     := SqlCode;
               cObservaTrz  := 'Insert Datos de garanseg(2): Error '||nSqlCode||' '||nSqlerrm||' '||cObservaTrz;
            END;
           ELSIF v_crespue <> 2 THEN*/
           -- FIN -  29/08/2020 - Company - AR 37070 - Incidencias HU-EMI-PW-APGP-012
           -- FIN - 11/09/2020 - Company - AR 37166 - Incidencias HU-EMI-APGP-004 

--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB                             
           BEGIN
            INSERT INTO garanseg
                        (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden,
                         ctarifa, icapital, icaptot, iprianu, ipritar, ipritot, ftarifa,
                         crevali)
           (SELECT G.cgarant, '1', '1', psseguro, G.finiefe, G.norden,
                   G.ctarifa, 
                   G.icapital, 
                   G.icaptot, 
                   -- INICIO PYALLTIT 06062020
                   G.iprianu, --/ xcforpag_rec,   -- G.iprianu,
                   -- FIN PYALLTIT 06062020
                   --(G.icaptot * 10) / 100, -- G.iprianu,
                   -- INICIO PYALLTIT 06062020
                   G.ipritar,  --/ xcforpag_rec,   -- G.ipritar, 
                   G.ipritot,  --/ xcforpag_rec,   -- G.ipritot, 
                   -- FIN PYALLTIT 06062020
                   G.ftarifa,
                   G.crevali                  
            FROM garanseg G, SEGUROS S
            WHERE G.SSEGURO = S.SSEGURO
            AND   S.NCERTIF = 0 
            AND   G.nmovimi = (SELECT MAX(C2.nmovimi)  FROM garanseg C2 WHERE C2.SSEGURO = G.SSEGURO) 
            AND   S.NPOLIZA = pnpoliza
            AND   G.NRIESGO = P_NPLAN);--STM r : NRIESGO = P_NPLAN
         EXCEPTION
            WHEN OTHERS THEN
            nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT GARANSEG ', SQLERRM);
         END;
--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB        
            IF nExisteError = 0 THEN
               cObservaTrz  := 'Insert Datos de garanseg(1): '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
            END IF;
           -- INICIO - 11/09/2020 - Company - AR 37166 - Incidencias HU-EMI-APGP-004 
           -- INICIO -  27/08/2020 - Company - AR 37035 - Incidencias HU-EMI-APGP-017
           --END IF;
           -- FIN -  27/08/2020 - Company - AR 37035 - Incidencias HU-EMI-APGP-017
           -- FIN - 11/09/2020 - Company - AR 37166 - Incidencias HU-EMI-APGP-004   
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '6097 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
         ELSIF NVL(nExisteAseg,0) <>  0 THEN
--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB                        
         -- INICIO - 11/09/2020 - Company - AR 37166 - Incidencias HU-EMI-APGP-004 
         -- INICIO -  29/08/2020 - Company - AR 37035 - Incidencias HU-EMI-APGP-017
         -- Si es prima por presupuesto no debe calcular prima
         /*IF v_crespue = 2 THEN
           BEGIN
             INSERT INTO garanseg(cgarant, nriesgo, nmovimi, sseguro, finiefe, norden,ctarifa, icapital, icaptot, iprianu, 
                                  ipritar, ipritot, ftarifa,crevali)
             (SELECT G.cgarant, G.nriesgo, NVL(G.nmovimi,0) + 1, psseguro, G.finiefe, G.norden,G.ctarifa,G.icapital,G.icaptot, 
              0,0,0,G.ftarifa,G.crevali
              FROM garanseg G, SEGUROS S
              WHERE G.SSEGURO = S.SSEGURO
              AND   G.nmovimi = (SELECT MAX(C2.nmovimi)  FROM garanseg C2 WHERE C2.SSEGURO = G.SSEGURO) 
              AND   S.NPOLIZA = pnpoliza
              AND   G.SSEGURO = PSSEGUROASEG
              AND   G.NRIESGO = P_NPLAN);--STM r : NRIESGO = P_NPLAN
           EXCEPTION
              WHEN OTHERS THEN
                nExisteError := 1;
                nSqlerrm     := Sqlerrm;
                nSqlCode     := SqlCode;
                cObservaTrz  := 'Insert Datos de garanseg(2): Error '||nSqlCode||' '||nSqlerrm||' '||cObservaTrz;
           END;
         ELSIF v_crespue <> 2 THEN*/
         -- FIN -  29/08/2020 - Company - AR 37035 - Incidencias HU-EMI-APGP-017
         -- FIN - 11/09/2020 - Company - AR 37166 - Incidencias HU-EMI-APGP-004 
          BEGIN
           INSERT INTO garanseg
                        (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden,
                         ctarifa, icapital, icaptot, iprianu, ipritar, ipritot, ftarifa,
                         crevali)
           (SELECT G.cgarant, G.nriesgo, NVL(G.nmovimi,0) + 1, psseguro, G.finiefe, G.norden,
                   G.ctarifa, 
                   G.icapital, 
                   G.icaptot, 
                   -- INICIO PYALLTIT 06062020
                   G.iprianu, --/ xcforpag_rec,   -- G.iprianu ,
                   -- FIN PYALLTIT 06062020
                  -- (G.icaptot * 10) / 100, -- G.iprianu, 
                   -- INICIO PYALLTIT 06062020
                   G.ipritar, --/ xcforpag_rec,   -- G.ipritar, 
                   G.ipritot,  --/ xcforpag_rec,   -- G.ipritot, 
                   -- FIN PYALLTIT 06062020
                   G.ftarifa,
                   G.crevali
            FROM garanseg G, SEGUROS S
            WHERE G.SSEGURO = S.SSEGURO
            AND   G.nmovimi = (SELECT MAX(C2.nmovimi)  FROM garanseg C2 WHERE C2.SSEGURO = G.SSEGURO) 
            AND   S.NPOLIZA = pnpoliza
            AND   G.SSEGURO = PSSEGUROASEG
            AND   G.NRIESGO = P_NPLAN);--STM r : NRIESGO = P_NPLAN
         EXCEPTION
            WHEN OTHERS THEN
             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT GARANSEG 2 ', SQLERRM);
        END;
        -- INICIO - 11/09/2020 - Company - AR 37166 - Incidencias HU-EMI-APGP-004 
        -- INICIO -  27/08/2020 - Company - AR 37035 - Incidencias HU-EMI-APGP-017
        --END IF;
        -- FIN -  27/08/2020 - Company - AR 37035 - Incidencias HU-EMI-APGP-017
        -- FIN - 11/09/2020 - Company - AR 37166 - Incidencias HU-EMI-APGP-004 

--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB        
            IF nExisteError = 0 THEN
               cObservaTrz  := 'Insert Datos de garanseg(2): '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
            END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '6165 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
         END IF;
   -- INICIO PYALLTIT
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '6168 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
   IF NVL(nExisteAseg,0) = 0 THEN
     -- INSERTA EL RECIBO DE PRODUCCION EN CERTIFICADO POR ASEGURADO
     -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
     --num_err := f_insrecibo(psseguro, pcagente, pfemisio, 
     num_err := f_insrecibo(psseguro, pcagente, f_sysdate,
     -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
                                   --- INICIO PYALLTIT  06062020
                                   TO_DATE(cFechaingresopoliza,'DD/MM/RRRR'), --pfefecto,
                                   -- INICIO - 24/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
                                   --v_fcarant,
                                   v_fcarpro,
                                   -- FIN - 24/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
                                   --dFVENCIM,
                                   --pfvencimi,
                                   --- FIN PYALLTIT  06062020
                                   pctiprec, pnanuali, pnfracci, pccobban, pcestimp, NULL,
                                   num_recibo, pmodo, psproces, pcmovimi, lnmovimi, pfefecto,
                                   'CERTIF0', xcforpag_rec, NULL, pttabla, pfuncion,   
                                   NULL, pcdomper);
     IF num_err <> 0 THEN
       p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR F_INSRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
       RETURN num_err;
     END IF;
     -- INICIO - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP
     BEGIN
       INSERT INTO msv_recibos(id_cargue,proceso,recibo,estado)
       VALUES(v_idcargue, v_sproces, num_recibo, 0);
     EXCEPTION
       WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR INSERT MSV_RECIBOS ', SQLERRM);
     END;
     -- FIN - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '6203 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
     -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
     BEGIN
       UPDATE RECIBOS SET CESTIMP = 1
       WHERE nrecibo = num_recibo;
       COMMIT;
     EXCEPTION
       WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR UPDATE RECIBOS SET CESTIMP', SQLERRM);
     END;
     -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo

    BEGIN

    Insert into adm_recunif (NRECIBO,NRECUNIF,SDOMUNIF) values (num_recibo,P_RECIBO,null);

    COMMIT;
    EXCEPTION
       WHEN OTHERS THEN
             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT ADM_RECUNIF ', SQLERRM);
   END;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '6225 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
    BEGIN 
      SELECT count(NRECIBO)
      INTO NRNRECIBO
      from MOVRECIBO where NRECIBO = num_recibo;
      IF NRNRECIBO = 0 THEN
      SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(17, 'USER_BBDD')) INTO vctx FROM dual; 
      Insert into MOVRECIBO (SMOVREC,NRECIBO,CUSUARI,SMOVAGR,CESTREC,CESTANT,FMOVINI,FMOVFIN,FCONTAB,FMOVDIA,
                       CMOTMOV,CCOBBAN,CDELEGA,CTIPCOB,FEFEADM,CGESCOB,TMOTMOV) 
            values ((SELECT MAX(SMOVREC) + 1  FROM MOVRECIBO),num_recibo,F_USER,'5231881','0','0',to_date(SYSDATE,'DD/MM/RRRR'),
                    null,to_date(SYSDATE,'DD/MM/RRRR'),to_date(SYSDATE,'DD/MM/RRRR'),null,null,'40',
                    null,to_date(SYSDATE,'DD/MM/RRRR'),null,null);
      END IF;
    EXCEPTION
       WHEN OTHERS THEN
             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT MOVRECIBO ' , SQLERRM);
 END;
            IF nExisteError = 0 THEN
               cObservaTrz  := 'Insert Datos de Recibos: '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
            END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '6246 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB  
     --- INICIO PYALLTIT  06062020
        -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        --nPeriodo       := ABS((dFEFECTO)  - TRUNC(dFVENCIM)); 
        /*
        IF TRUNC(dFEFECTO) <> Trunc(to_date(cFechaingresopoliza,'DD/MM/RR')) THEN
        nPeriodo := (TRUNC(v_fcarant) - trunc(to_date(cFechaingresopoliza,'DD/MM/RRRR')));
          -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
          --IF nPeriodo >= 28 and nPeriodo <= 31 THEN
            --nPeriodo := 365;
          --END IF;
          -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        nFactor  := nPeriodo / 365;
        ELSE
          nPeriodo       := ABS((dFEFECTO)  - TRUNC(dFVENCIM)); 
          nDiasCobrar  := ABS(trunc(to_date(cFechaingresopoliza,'DD/MM/RRRR')) - TRUNC(dFVENCIM));
        END IF;
        */
        -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo

        -- INICIO - 19/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        /* Para los calculos del factor de dias a liquidar en la prima se toma como referencia el fcarant de la caratula,
        cuando no se ha renovado o esta null, el v_fcarant toma el fcarpro. 
        se hacen las restas entre las fechas y para la liquidacion normal se calcula la diferencia de dias dividida entre
        360 para el prorrateo se calculan las fechas restantes con respecto a la fecha de vencimiento de la caratula y se
        divide en 365.

        Despues de renovar para el calculo del factor a liquidar despues del recibo se toma como referencia la fecha de
        la cartera actual.

        */
        v_fvenccar      := dFVENCIM;

        --v_ffinrec       := v_fcarant;

        -- INICIO - 19/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        v_fvenccar      := dFVENCIM;

        v_fefectocert   := cFechaingresopoliza;

        SELECT fcarant 
        INTO v_fcarantcar 
        FROM SEGUROS
        WHERE npoliza = pnpoliza
        AND ncertif = 0;

        SELECT fcarpro 
        INTO v_fcarprocar 
        FROM SEGUROS
        WHERE npoliza = pnpoliza
        AND ncertif = 0;

        SELECT EXTRACT(MONTH FROM LAST_DAY(v_fcarprocar)) 
        INTO v_mesfcarprocar
        FROM dual;

        SELECT EXTRACT(MONTH FROM LAST_DAY(v_fefectocert)) 
        INTO v_mesfefectocert 
        FROM dual;

        SELECT TRUNC(v_fefectocert,'MM') 
        INTO v_primdiamesfefecto
        FROM DUAL;

        -- 365 O 366 si el anio es bisiesto
        SELECT ADD_MONTHS(TO_DATE('0101' || EXTRACT(YEAR FROM LAST_DAY(dFEFECTO)), 'ddmmyyyy'), 12) 
        - TO_DATE('0101' || EXTRACT(YEAR FROM LAST_DAY(dFEFECTO)), 'ddmmyyyy') 
        INTO v_diasanio
        FROM DUAL;

        -- Periodicidad mensual cforpag= 12
        IF xcforpag_rec = 12 THEN
          -- No se ha renovado aun
          IF v_fcarantcar IS NULL THEN
            v_difdias       := v_fcarant - v_fefectocert;

            SELECT EXTRACT(MONTH FROM LAST_DAY(v_fefectocert)) 
            INTO v_mesfefecto 
            FROM dual;

            -- Meses de 30 dias: abril, junio, septiembre y noviembre
            IF v_mesfefecto IN (4,6,9,11) AND ( v_difdias = 30 ) THEN
              v_noprorrat := TRUE;

            -- Meses de 31 dias: enero, marzo, mayo, julio, agosto, octubre, diciembre 
            ELSIF v_mesfefecto IN (1,3,5,7,8,10,12) AND ( v_difdias = 31 ) THEN
              v_noprorrat := TRUE;

            -- Febrero (28-29 dias)
            ELSIF (v_mesfefecto = 2) AND v_difdias IN (28,29) THEN
              v_noprorrat := TRUE;

            END IF;

            -- No hay prorrata
            IF v_noprorrat = TRUE THEN
              v_facnet        := 30 / 360;
              v_facdev        := 1;

            -- Se aplica prorrateo
            ELSE
              nerror          := f_difdata(v_fefectocert, v_fcarant, 1, 3, v_difdiasval);
              nerror          := f_difdata(v_fefectocert, v_fvenccar, 1, 3, v_difdiasanu); --v_fvenccar - v_fefectocert;

              v_facnet        := v_difdiasval / 365;
              v_facdev        := v_difdiasanu / 365;

            END IF;
          -- Ya se renovo
          ELSE

            -- Fecha efecto certificado es igual a la fecha de efecto caratula
            IF v_fefectocert = dFEFECTO THEN
              v_peradic := v_mesfcarprocar - v_mesfefectocert;
              v_difdias := 0;

              -- Se calcula el factor para liquidar la prima
              v_facnet        := ( (30 * v_peradic)/ 360 ) + ( v_difdias/360 );
              v_facdev        := 1;

            ELSE
              v_difdias := v_fcarprocar - v_fefectocert;
              v_difdias := MOD(v_difdias,30);
              v_peradic := f_round(v_difdias/30, null);

              nerror          := f_difdata(v_fefectocert, LAST_DAY(v_fefectocert) + 1, 1, 3, v_difdiasval);
              nerror          := f_difdata(v_fefectocert, v_fvenccar, 1, 3, v_difdiasanu); --v_fvenccar - v_fefectocert;

              v_facnet :=  ( (30 * v_peradic)/ 360 ) + ( v_difdiasval/365 );
              v_facdev :=  ( (30 * v_peradic)/ 360 ) + ( v_difdiasanu/365 );

            END IF;

          END IF;
        -- Periodicidad trimestral cforpag= 4
        ELSIF xcforpag_rec = 4 THEN

          -- No se ha renovado aun
          IF v_fcarantcar IS NULL THEN

            v_difdias       := v_fcarant - v_fefectocert;

            IF v_fefectocert = dFEFECTO THEN
              -- INICIO - 07/04/2021 - Company - Ar 38673 - Inconsistencia valor recibos prima trimestral
              --v_facnet        :=  v_difdias/ 360;
              v_facnet        :=  90/ 360;
              -- FIN - 07/04/2021 - Company - Ar 38673 - Inconsistencia valor recibos prima trimestral
              v_facdev        := 1;

            -- Se aplica prorrateo
            ELSE
              nerror          := f_difdata(v_fefectocert, v_fcarant, 1, 3, v_difdiasval);
              nerror          := f_difdata(v_fefectocert, v_fvenccar, 1, 3, v_difdiasanu);

              v_facnet        := v_difdiasval / 365;
              v_facdev        := v_difdiasanu / 365;

            END IF;
          -- Ya se renovo
          ELSE

            -- Fecha efecto certificado es igual a la fecha de efecto caratula
            IF v_fefectocert = dFEFECTO THEN

              v_peradic := (v_mesfcarprocar - v_mesfefectocert) / 3;
              v_difdias := 0;

              -- Se calcula el factor para liquidar la prima
              v_facnet        := ( (90 * v_peradic)/ 360 ) + ( v_difdias/360 );
              v_facdev        := 1;

            ELSE
              v_difdias := v_fcarprocar - v_fefectocert;

              v_difdias := MOD(v_difdias,90);

              v_peradic := f_round(v_difdias/90, null);

              nerror          := f_difdata(v_fefectocert, (v_primdiamesfefecto + 90), 1, 3, v_difdiasval);

              nerror          := f_difdata(v_fefectocert, v_fvenccar, 1, 3, v_difdiasanu);

              v_facnet :=  ( (90 * v_peradic)/ 360 ) + ( v_difdiasval/365 );

              v_facdev :=  ( (90 * v_peradic)/ 360 ) + ( v_difdiasanu/365 );

            END IF;

          END IF;

        -- Periodicidad semestral cforpag= 2
        ELSIF xcforpag_rec = 2 THEN

          -- No se ha renovado aun
          IF v_fcarantcar IS NULL THEN

            v_difdias       := v_fcarant - v_fefectocert;

            IF v_fefectocert = dFEFECTO THEN
              v_facnet        :=  180/ 360;
              v_facdev        := 1;

            -- Se aplica prorrateo
            ELSE
              nerror          := f_difdata(v_fefectocert, v_fcarant, 1, 3, v_difdiasval);
              nerror          := f_difdata(v_fefectocert, v_fvenccar, 1, 3, v_difdiasanu);

              v_facnet        := v_difdiasval / 365;
              v_facdev        := v_difdiasanu / 365;

            END IF;
          -- Ya se renovo
          ELSE

            -- Fecha efecto certificado es igual a la fecha de efecto caratula
            IF v_fefectocert = dFEFECTO THEN

              v_peradic := f_round( ((v_fcarprocar - v_fefectocert) / 180),null);
              v_difdias := 0;

              -- Se calcula el factor para liquidar la prima
              v_facnet        := ( (180 * v_peradic)/ 360 ) + ( v_difdias/360 );
              v_facdev        := 1;

            ELSE
              v_difdias := v_fcarprocar - v_fefectocert;

              v_peradic := trunc(v_difdias/180);

              nerror          := f_difdata(v_fefectocert, last_day(v_primdiamesfefecto + 180), 1, 3, v_difdiasval);

              nerror          := f_difdata(v_fefectocert, v_fvenccar, 1, 3, v_difdiasanu);

              v_facnet :=  ( (180 * v_peradic)/ 360 ) + ( v_difdiasval/365 );

              v_facdev :=  ( (180 * v_peradic)/ 360 ) + ( v_difdiasanu/365 );

            END IF;

          END IF;

        -- Periodicidad anual cforpag= 1
        ELSIF xcforpag_rec = 1 THEN

          -- No se ha renovado aun
          IF v_fcarantcar IS NULL THEN
            v_difdias       := v_fcarant - v_fefectocert;

            -- No hay prorrata
            IF v_difdias = v_diasanio THEN
              v_facnet        := 1;
              v_facdev        := 1;

            -- Se aplica prorrateo
            ELSE
              nerror          := f_difdata(v_fefectocert, v_fcarant, 1, 3, v_difdiasval);
              nerror          := f_difdata(v_fefectocert, v_fvenccar, 1, 3, v_difdiasanu); --v_fvenccar - v_fefectocert;

              v_facnet        := v_difdiasval / v_diasanio;
              v_facdev        := v_difdiasanu / v_diasanio;

            END IF;
          -- Ya se renovo
          ELSE
            -- Fecha efecto certificado es igual a la fecha de efecto caratula
            IF v_fefectocert = dFEFECTO THEN

              SELECT EXTRACT(YEAR FROM LAST_DAY(v_fcarprocar)) 
              INTO v_aniofcarprocar
              FROM dual;

              SELECT EXTRACT(YEAR FROM LAST_DAY(v_fefectocert)) 
              INTO v_aniofefectocert
              FROM dual;

              v_peradic := v_aniofcarprocar - v_aniofefectocert;
              v_difdias := 0;

              -- Se calcula el factor para liquidar la prima
              v_facnet        := ( (360 * v_peradic)/ 360 ) + ( v_difdias/360 );
              v_facdev        := 1;

            ELSE
              v_difdias := v_fcarprocar - v_fefectocert;
              v_difdias := MOD(v_difdias,30);
              v_peradic := f_round(v_difdias/30, null);

              nerror          := f_difdata(v_fefectocert, LAST_DAY(v_fefectocert) + 1, 1, 3, v_difdiasval);
              nerror          := f_difdata(v_fefectocert, v_fvenccar, 1, 3, v_difdiasanu); --v_fvenccar - v_fefectocert;

              v_facnet :=  ( (360 * v_peradic)/ 360 ) + ( v_difdiasval/v_diasanio );
              v_facdev :=  ( (360 * v_peradic)/ 360 ) + ( v_difdiasanu/v_diasanio );

            END IF;

          END IF;

        END IF; -- XFORPAC_REC
        -- FIN - 19/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo

        TOTALPRIMA := 0 ;
      --  INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
      BEGIN
        SELECT sseguro, ctipcom
        INTO v_sseguro_0, v_ctipcom 
        FROM seguros WHERE npoliza = pnpoliza AND ncertif = 0;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      -- Se obtiene el porcentaje de comision

      v_comisi := PAC_ENVIO_PRODUCCION_COL.F_PRI_COMISION(v_sseguro_0,1,num_recibo,v_ctipcom);
      -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      v_comisi := (nvl(v_comisi,0) / 100);
      -- Se obtiene el porcentaje de coaseguro CEDIDO
      BEGIN
        SELECT sum(pcescoa)
          INTO v_coacedido
          FROM coacedido
         WHERE sseguro = v_sseguro_0
           AND ncuacoa = (SELECT MAX(ncuacoa) FROM coacedido WHERE sseguro = v_sseguro_0);
      EXCEPTION
        WHEN OTHERS THEN
          v_coacedido := 0;
      END;

      -- Se obtiene el porcentaje de coaseguro a nombre de Positiva
      /* BEGIN
        SELECT ploccoa
          INTO v_coapos
          FROM coacuadro
          WHERE sseguro = v_sseguro_0
          AND ncuacoa = (SELECT MAX(ncuacoa) FROM coacedido WHERE sseguro = v_sseguro_0);
      EXCEPTION
        WHEN OTHERS THEN
          v_coapos := 0;
      END;*/
      -- Coaseguro de positiva
      v_coacedido := (nvl(v_coacedido,0) / 100);

      -- Coaseguro cedido a otras aseguradoras
      IF NVL(v_coacedido,0) > 0 THEN
        v_coapos := 1 - v_coacedido;

      END IF;

      -- Polizas que no tienen coaseguro
      IF v_coapos = 0 THEN
        v_coapos := 1;

      END IF;
      -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      --  FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '6601 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
      -- INICIO - 19/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      FOR y IN(SELECT 
                 G.IPRIANU IPRIANU,
                 G.CGARANT, 
                 G.nriesgo, 
                 G.nmovimi
               FROM GARANSEG G
              WHERE G.SSEGURO = psseguro
                AND   G.nmovimi = 1
                AND   G.NRIESGO = 1) LOOP

        v_prifacnet := f_round(y.iprianu * v_facnet,null);
        v_prifacdev := f_round(y.iprianu * v_facdev,null);

        -- Prima Neta (Concepto 0)
        v_concep := f_round((v_prifacnet * NVL(v_coapos,1)),NULL);

        -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
        --num_err := f_insdetrec(num_recibo,0,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,NULL,NULL,NULL,0);
        num_err := f_insdetrec(num_recibo,0,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,v_concep,SYSDATE,NULL,0);
        IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR F_INSDETRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
        END IF;
        -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
        
        -- Comision Bruta (Concepto 11)
        v_concep := f_round((v_concep * v_comisi),NULL);

        -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
        --num_err := f_insdetrec(num_recibo,11,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,NULL,NULL,NULL,0);
        num_err := f_insdetrec(num_recibo,11,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,v_concep,SYSDATE,NULL,0);
        IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR F_INSDETRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
        END IF;
        -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo

        -- Prima Devengada (Concepto 21)
        v_concep := f_round((v_prifacdev * v_coapos),NULL);
        -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
        --num_err := f_insdetrec(num_recibo,21,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,NULL,NULL,NULL,0);
        num_err := f_insdetrec(num_recibo,21,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,v_concep,SYSDATE,NULL,0);
        IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR F_INSDETRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
        END IF;
        -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo

        -- Comision Devengada (Concepto 15)
        v_concep := f_round((v_prifacdev * v_comisi * v_coapos),NULL);
        BEGIN
        INSERT INTO detrecibos(nrecibo, cconcep, cgarant, nriesgo,iconcep,cageven,nmovima,iconcep_monpol,fcambio)
             VALUES (num_recibo, 15, y.cgarant, cPlan,v_concep, null, 1, v_concep, f_sysdate);
        COMMIT;
        END;

        IF NVL(v_coapos,0) < 1 THEN
          -- Prima Neta Cedido (Concepto 50)
          v_concep := f_round((v_prifacnet * v_coacedido),NULL);
          -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
          --num_err := f_insdetrec(num_recibo,50,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,NULL,NULL,NULL,0);
          num_err := f_insdetrec(num_recibo,50,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,v_concep,sysdate,NULL,0);
          IF num_err <> 0 THEN
           p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR F_INSDETRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
          END IF;
          -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo

          -- Comision Bruta Cedido (Concepto 61)
          v_concep := f_round((v_concep * v_comisi),NULL);
          -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
          --num_err := f_insdetrec(num_recibo,61,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,NULL,NULL,NULL,0);
          num_err := f_insdetrec(num_recibo,61,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,v_concep,sysdate,NULL,0);
          IF num_err <> 0 THEN
           p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR F_INSDETRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
          END IF;
          -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo

          -- Comision Devengada Cedido (Concepto 65)
          v_concep := f_round((v_prifacdev * v_comisi * v_coacedido),NULL);
          -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
          --num_err := f_insdetrec(num_recibo,65,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,NULL,NULL,NULL,0);
          num_err := f_insdetrec(num_recibo,65,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,v_concep,sysdate,NULL,0);
          IF num_err <> 0 THEN
           p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR F_INSDETRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
          END IF;
          -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo

          -- Prima Devengada Cedido (Concepto 71)
          v_concep := f_round((v_prifacdev * v_coacedido),NULL);
          -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
          --num_err := f_insdetrec(num_recibo,71,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,NULL,NULL,NULL,0);
          num_err := f_insdetrec(num_recibo,71,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,v_concep,sysdate,NULL,0);
          IF num_err <> 0 THEN
           p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR F_INSDETRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
          END IF;
          -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
          
        END IF;
      END LOOP;
      -- FIN - 19/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '6700 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
/*
      FOR y IN(SELECT 
             --- INICIO PYALLTIT  06062020
             -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
             --ROUND((( (G.IPRIANU/xcforpag_rec) / nPeriodo) * nDiasCobrar),2) IPRIANU,
             --ROUND(((G.IPRIANU / nPeriodo) * nDiasCobrar),2) IPRIANU,
             G.IPRIANU IPRIANU,
             -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
             --  G.IPRIANU / NVL(xcforpag_rec,1) IPRIANU,
             --- FIN PYALLTIT  06062020
             G.CGARANT, G.nriesgo, G.nmovimi
             FROM GARANSEG G
             WHERE G.SSEGURO = psseguro
             AND   G.nmovimi = 1
             AND   G.NRIESGO = 1) LOOP --STM : NRIESGO = P_NPLAN STMR
--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB             
      BEGIN


        -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        IF TRUNC(dFEFECTO) <> Trunc(to_date(cFechaingresopoliza,'DD/MM/RRRR')) THEN 
          v_iprianu := ROUND((y.iprianu * nFactor),2);

        ELSE
          v_iprianu := ROUND((( (y.iprianu/xcforpag_rec) / nPeriodo) * nDiasCobrar),2);

        END IF;
        -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo

      --  INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
      IF v_coapos > 0 THEN
        --v_concep := y.iprianu * (v_coacedido /100);
        v_concep := v_iprianu * v_coapos;
      ELSE
        --v_concep := y.iprianu;
        v_concep := v_iprianu;
      -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      END IF;
      -- Prima Neta (Concepto 0)

      num_err := f_insdetrec(num_recibo, --pnrecibo,
                             0,
                             v_concep,
                             NULL, --xploccoa,
                             y.CGARANT, 
                             cPlan,
                             NULL, --xctipcoa,
                             NULL, --xcageven_gar,
                             1, --xnmovima_gar,
                             0, --xccomisi,
                             psseguro,
                             1,
                             NULL,
                             NULL,
                             NULL,
                             0 --decimals
                             );

      IF num_err <> 0 THEN
        RETURN num_err;
      END IF;
      -- Prima Neta Cedido (Concepto 50)
      -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      --v_concep := y.iprianu * ( (100 - v_coacedido) /100);
      v_concep := v_iprianu * v_coacedido;
      --v_concep := TRUNC(v_concep);
      -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo

      IF v_coacedido > 0 THEN

        num_err := f_insdetrec(num_recibo, --pnrecibo,
                               50,
                               v_concep,
                               NULL, --xploccoa,
                               y.CGARANT, 
                               cPlan,
                               NULL, --xctipcoa,
                               NULL, --xcageven_gar,
                               1, --xnmovima_gar,
                               0, --xccomisi,
                               psseguro,
                               1,
                               NULL,
                               NULL,
                               NULL,
                               0 --decimals
                              );
        IF num_err <> 0 THEN
          RETURN num_err;
        END IF;
      END IF;
      IF v_comisi > 0 THEN

        --v_concep_cb := v_concep * (v_comisi /100);
        IF v_coapos > 0 THEN
        -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        --v_concep := y.iprianu * (v_coacedido /100);
        v_concep := v_iprianu * v_coapos;
        v_concep_cb := v_concep * v_comisi;
        ELSE
        --v_concep_cb := y.iprianu * (v_comisi /100);
        v_concep_cb := v_iprianu * v_comisi;
        -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        END IF;

        -- Comision Bruta (Concepto 11)
        num_err := f_insdetrec(num_recibo, --pnrecibo,
                               11,
                               v_concep_cb,
                               NULL, --xploccoa,
                               y.CGARANT, 
                               cPlan,
                               NULL, --xctipcoa,
                               NULL, --xcageven_gar,
                               1, --xnmovima_gar,
                               0, --xccomisi,
                               psseguro,
                               1,
                               NULL,
                               NULL,
                               NULL,
                               0 --decimals
                               ); 
        IF num_err <> 0 THEN
          RETURN num_err;
        END IF;
      END IF;
      IF v_coacedido > 0 AND v_comisi > 0 THEN
        -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        --v_concep := y.iprianu * ( (100 - v_coacedido) /100);
        v_concep := v_iprianu * v_coacedido;
        -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        v_concep_cb := v_concep * v_comisi;

        -- Comision Bruta - Cedido (Concepto 61)
        num_err := f_insdetrec(num_recibo, --pnrecibo,
                               61,
                               v_concep_cb,
                               NULL, --xploccoa,
                               y.CGARANT, 
                               cPlan,
                               NULL, --xctipcoa,
                               NULL, --xcageven_gar,
                               1, --xnmovima_gar,
                               0, --xccomisi,
                               psseguro,
                               1,
                               NULL,
                               NULL,
                               NULL,
                               0 --decimals
                               ); 
        IF num_err <> 0 THEN
          RETURN num_err;
        END IF;
      END IF;

      TOTALPRIMA :=      ROUND(TOTALPRIMA     + y.IPRIANU); 
      --  FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
       COMMIT;
      EXCEPTION
       WHEN OTHERS THEN
             nExisteError := 1;
             nSqlerrm     := Sqlerrm;
             nSqlCode     := SqlCode;
             cObservaTrz  := 'Insert Datos de Detalle Recibos: Error '||nSqlCode||' '||nSqlerrm;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT DETRECIBOS1 cObservaTrz = ' || cObservaTrz, SQLERRM);
        END;
            IF nExisteError = 0 THEN
               cObservaTrz  := 'Insert Datos de Detalle Recibos: '||psseguro||' lncertif: '||lncertif||' Y.CGARANT: '||Y.CGARANT||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
            END IF;
     END LOOP;
     */
/*
     --  INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
     FOR y IN (SELECT
               -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
               --ROUND((( (G.IPRIANU/xcforpag_rec) / nPeriodo) * nDiasCobrar),2) IPRIANU,
               --ROUND(((G.IPRIANU / nPeriodo) * nDiasCobrar),2) IPRIANU,
               G.IPRIANU IPRIANU,
               -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
               G.CGARANT, G.nriesgo, G.nmovimi
               FROM GARANSEG G
               WHERE G.SSEGURO = (select sseguro from seguros where npoliza = pnpoliza AND ncertif = 0)
               -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
               --AND   G.nmovimi = 1
               AND   G.nmovimi = (SELECT MAX(NMOVIMI) FROM GARANSEG WHERE SSEGURO = (select sseguro from seguros where npoliza = pnpoliza AND ncertif = 0) )
               -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
               AND   G.NRIESGO = 1) LOOP

       BEGIN
        -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        IF TRUNC(dFEFECTO) <> Trunc(to_date(cFechaingresopoliza,'DD/MM/RRRR')) THEN 
          v_iprianu := ROUND((y.iprianu * nFactor),2);

        ELSE
          --v_iprianu := ROUND((( (y.iprianu/xcforpag_rec) / nPeriodo) * nDiasCobrar),2);
          v_iprianu := y.iprianu;

        END IF;
         --IF v_coacedido > 0 AND v_comisi > 0 THEN
         IF v_comisi > 0 THEN
           IF v_coapos > 0 THEN
           -- Comision Devengada (Concepto 15)
           --v_coadev   :=  y.iprianu * ( ( v_coacedido) /100);
           v_coadev   :=  v_iprianu * v_coapos;
           v_comdev   := v_coadev * v_comisi;

           ELSE
             --v_comdev :=  y.iprianu *  (v_comisi/100);
             v_comdev :=  v_iprianu * v_comisi;
           END IF;
           -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo

           BEGIN
             INSERT INTO detrecibos
                       -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
                              --(nrecibo, cconcep, cgarant, nriesgo,iconcep)
                              (nrecibo, cconcep, cgarant, nriesgo,iconcep,cageven,nmovima,iconcep_monpol,fcambio)
                       --VALUES (nnrecibo, 15, y.cgarant, cPlan,v_comdev);
                       VALUES (num_recibo, 15, y.cgarant, cPlan,v_comdev, null, 1, v_comdev, f_sysdate);
                       -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
           EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT DETRECIBOS 2 cObservaTrz = ' || cObservaTrz, SQLERRM);
           END;
           -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
           IF v_coacedido > 0 THEN
           -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
           --v_coadev   :=  y.iprianu * ( (100 - v_coacedido) /100);
           v_coadev   :=  v_iprianu * v_coacedido;
           -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
           v_comdev   := v_coadev * v_comisi;

           -- Comision Devengada - Cedido (Concepto 65)
           num_err := f_insdetrec(num_recibo, --pnrecibo,
                                  65,
                                  v_comdev,
                                  NULL, --xploccoa,
                                  y.CGARANT, 
                                  cPlan,
                                  NULL, --xctipcoa,
                                  NULL, --xcageven_gar,
                                  1, --xnmovima_gar,
                                  0, --xccomisi,
                                  psseguro,
                                  1,
                                  NULL,
                                  NULL,
                                  NULL,
                                  0 --decimals
                                  );
           IF num_err <> 0 THEN
             RETURN num_err;
           END IF;
           -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
           END IF;
           -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
         END IF;
         IF v_coacedido > 0 THEN
           -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
           --v_coadev   :=  y.iprianu * ( (100 - v_coacedido) /100);
           v_coadev   :=  v_iprianu * v_coacedido;
           -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo

           -- Prima Devengada Cedido (Concepto 71)
           num_err := f_insdetrec(num_recibo, --pnrecibo,
                                  71,
                                  v_coadev,
                                  NULL, --xploccoa,
                                  y.CGARANT, 
                                  cPlan,
                                  NULL, --xctipcoa,
                                  NULL, --xcageven_gar,
                                  1, --xnmovima_gar,
                                  0, --xccomisi,
                                  psseguro,
                                  1,
                                  NULL,
                                  NULL,
                                  NULL,
                                  0 --decimals
                                  );
           IF num_err <> 0 THEN
             RETURN num_err;
           END IF;
         END IF;
         -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
         IF v_coapos > 0 then
         --v_coadev   :=  y.iprianu * ( ( v_coacedido) /100);
         v_coadev   :=  v_iprianu * v_coapos;
         ELSE
         --v_coadev   :=  y.iprianu;
         v_coadev   :=  v_iprianu;
         END IF;
         -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo

         -- Prima Devengada (Concepto 21)
         num_err := f_insdetrec(num_recibo, --pnrecibo,
                               21,
                               v_coadev,
                               NULL, --xploccoa,
                               y.CGARANT, 
                               cPlan,
                               NULL, --xctipcoa,
                               NULL, --xcageven_gar,
                               1, --xnmovima_gar,
                               0, --xccomisi,
                               psseguro,
                               1,
                               NULL,
                               NULL,
                               NULL,
                               0 --decimals
                               );
           IF num_err <> 0 THEN
             RETURN num_err;
           END IF;
       COMMIT;
       -- INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
       --TOTALPRIMA :=      TOTALPRIMA     + y.IPRIANU;
       --  FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
      EXCEPTION
       WHEN OTHERS THEN
             nExisteError := 1;
             nSqlerrm     := Sqlerrm;
             nSqlCode     := SqlCode;
             cObservaTrz  := 'Insert Datos de Detalle Recibos: Error '||nSqlCode||' '||nSqlerrm;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT DETRECIBOS 2 cObservaTrz = ' || cObservaTrz, SQLERRM);
        END;
    END LOOP;
    --  FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
    -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
    --nExisteError := f_vdetrecibos ('R', num_recibo);
    --IF nExisteError > 0 THEN
      --p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT VDETRECIBOS 1 nExisteError = ' || nExisteError, SQLERRM);
    --END IF;
    */

       SELECT ROUND(SUM(ICONCEP))
       INTO TOTALPRIMA
       FROM DETRECIBOS
       WHERE NRECIBO = num_recibo
       AND CCONCEP IN (0,50);
       --TOTALPRIMA := round(TOTALPRIMA);

       BEGIN
       Insert into VDETRECIBOS (NRECIBO,IPRINET,IRECEXT,ICONSOR,IRECCON,IIPS,IDGS,IARBITR,IFNG,IRECFRA,IDTOTEC,IDTOCOM,ICOMBRU,
       ICOMRET,IDTOOM,IPRIDEV,ITOTPRI,ITOTDTO,ITOTCON,ITOTIMP,ITOTALR,IDERREG,ITOTREC,ICOMDEV,IRETDEV,ICEDNET,ICEDREX,ICEDCON,
       ICEDRCO,ICEDIPS,ICEDDGS,ICEDARB,ICEDFNG,ICEDRFR,ICEDDTE,ICEDDCO,ICEDCBR,ICEDCRT,ICEDDOM,ICEDPDV,ICEDREG,ICEDCDV,ICEDRDV,
       IT1PRI,IT1DTO,IT1CON,IT1IMP,IT1REC,IT1TOTR,IT2PRI,IT2DTO,IT2CON,IT2IMP,IT2REC,IT2TOTR,ICOMCIA,ICOMBRUI,ICOMRETI,ICOMDEVI,
       ICOMDRTI,ICOMBRUC,ICOMRETC,ICOMDEVC,ICOMDRTC,IOCOREC,IIMP_1,IIMP_2,IIMP_3,IIMP_4,ICONVOLEODUCTO) 
       values (num_recibo,TOTALPRIMA,'0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMA,TOTALPRIMA,'0','0','0',TOTALPRIMA,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMA,'0','0','0','0',TOTALPRIMA,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');
       EXCEPTION
         WHEN OTHERS THEN
           nExisteError := 1;
           p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT VDETRECIBOS ', SQLERRM);
       END;
       BEGIN
       Insert into VDETRECIBOS_MONPOL (NRECIBO,IPRINET,IRECEXT,ICONSOR,IRECCON,IIPS,IDGS,IARBITR,IFNG,IRECFRA,IDTOTEC,IDTOCOM,
       ICOMBRU,ICOMRET,IDTOOM,IPRIDEV,ITOTPRI,ITOTDTO,ITOTCON,ITOTIMP,ITOTALR,IDERREG,ITOTREC,ICOMDEV,IRETDEV,ICEDNET,ICEDREX,
       ICEDCON,ICEDRCO,ICEDIPS,ICEDDGS,ICEDARB,ICEDFNG,ICEDRFR,ICEDDTE,ICEDDCO,ICEDCBR,ICEDCRT,ICEDDOM,ICEDPDV,ICEDREG,ICEDCDV,
       ICEDRDV,IT1PRI,IT1DTO,IT1CON,IT1IMP,IT1REC,IT1TOTR,IT2PRI,IT2DTO,IT2CON,IT2IMP,IT2REC,IT2TOTR,ICOMCIA,ICOMBRUI,ICOMRETI,
       ICOMDEVI,ICOMDRTI,ICOMBRUC,ICOMRETC,ICOMDEVC,ICOMDRTC,IOCOREC,IIMP_1,IIMP_2,IIMP_3,IIMP_4,ICONVOLEODUCTO) 
       values (num_recibo,TOTALPRIMA,'0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMA,TOTALPRIMA,'0','0','0',TOTALPRIMA,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMA,'0','0','0','0',TOTALPRIMA,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');
       EXCEPTION
         WHEN OTHERS THEN
           nExisteError := 1;
           p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT VDETRECIBOS_MONPOL ', SQLERRM);
       END;
    -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo

 --- INICIO PYALLTIT  17072020                                     
   IF pac_retorno.f_tiene_retorno(NULL, psseguro, NULL, 'SEG') = 1 THEN
      -- v_numerr := f_generar_retorno_pos(pnpoliza,psseguro, NVL(pcmovimi, lnmovimi), NULL,NULL);
     v_numerr2 := f_generar_retorno_pos(pnpoliza,psseguro, NULL, NULL,NULL);
   COMMIT;
   END IF;
   --- FIN PYALLTIT  17072020					 
   ELSIF NVL(nExisteAseg,0) <> 0 THEN
     -- INSERTA EL RECIBO DE PRODUCCION EN CERTIFICADO POR ASEGURADO
     -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
     --num_err := f_insrecibo(psseguro, pcagente, pfemisio, 
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '7084 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
     num_err := f_insrecibo(psseguro, pcagente, f_sysdate, 
     -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
                                   --- INICIO PYALLTIT  06062020
                                   TO_DATE(cFechaingresopoliza,'DD/MM/RRRR'), --pfefecto, 
                                  -- dFVENCIM, --
                                   -- INICIO - 24/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
                                   -- pfvencimi,
                                   v_fcarpro,
                                   -- FIN - 24/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
                                   --- FIN PYALLTIT  06062020
                                   -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
                                   pctiprec, pnanuali, pnfracci, pccobban, pcestimp, NULL,
                                   -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
                                   num_recibo, pmodo, psproces, pcmovimi, lnmovimi, pfefecto,
                                   'CERTIF0', xcforpag_rec, NULL, pttabla, pfuncion,   
                                   NULL, pcdomper);                                 
     IF num_err <> 0 THEN
       p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR F_INSRECIBO 2 NUM_ERR: ' || num_err, SQLERRM);
       RETURN num_err;
     END IF;
     -- INICIO - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP
     BEGIN
       INSERT INTO msv_recibos(id_cargue,proceso,recibo,estado)
       VALUES(v_idcargue, v_sproces, num_recibo, 0);
     EXCEPTION
       WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR INSERT MSV_RECIBOS ', SQLERRM);
     END;
     -- FIN - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP
     -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
     BEGIN
       UPDATE RECIBOS SET CESTIMP = 1
       WHERE nrecibo = num_recibo;
       COMMIT;
     EXCEPTION
       WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR UPDATE RECIBOS SET CESTIMP', SQLERRM);
     END;
     -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
    BEGIN
      Insert into adm_recunif (NRECIBO,NRECUNIF,SDOMUNIF) values (num_recibo,P_RECIBO,null);
    EXCEPTION
       WHEN OTHERS THEN
             nExisteError := 1;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT ADM_RECUNIF 2 ', SQLERRM);
        END;

            IF nExisteError = 0 THEN
               cObservaTrz  := 'Insert Datos de Recibos(2): '||psseguro||' lncertif: '||lncertif||' NSPERSON: '||NSPERSON||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
            END IF;
      --  INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
      BEGIN
        SELECT sseguro, ctipcom
        INTO v_sseguro_0, v_ctipcom 
        FROM seguros WHERE npoliza = pnpoliza AND ncertif = 0;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      -- Se obtiene el porcentaje de comision
      v_comisi := PAC_ENVIO_PRODUCCION_COL.F_PRI_COMISION(v_sseguro_0,1,num_recibo,v_ctipcom);
      -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      v_comisi := (nvl(v_comisi,0) / 100);
      -- Se obtiene el porcentaje de coaseguro CEDIDO
      BEGIN
        SELECT sum(pcescoa)
          INTO v_coacedido
          FROM coacedido
         WHERE sseguro = v_sseguro_0
           AND ncuacoa = (SELECT MAX(ncuacoa) FROM coacedido WHERE sseguro = v_sseguro_0);
      EXCEPTION
        WHEN OTHERS THEN
          v_coacedido := 0;
      END;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '7164 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
      -- Se obtiene el porcentaje de coaseguro a nombre de Positiva
      /*
      BEGIN
        SELECT ploccoa
          INTO v_coapos
          FROM coacuadro
          WHERE sseguro = v_sseguro_0
          AND ncuacoa = (SELECT MAX(ncuacoa) FROM coacedido WHERE sseguro = v_sseguro_0);
      EXCEPTION
        WHEN OTHERS THEN
          v_coapos := 0;
      END;*/
      v_coacedido := (nvl(v_coacedido,0) / 100);
      --v_coapos := (nvl(v_coapos,0) / 100);
      IF NVL(v_coacedido,0) > 0 THEN
        v_coapos := 1 - v_coacedido;
      END IF;

      -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      --  FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
      -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      --nPeriodo       := ABS((dFEFECTO)  - TRUNC(dFVENCIM)); 
      /*IF TRUNC(dFEFECTO) <> Trunc(to_date(cFechaingresopoliza,'DD/MM/RRRR')) THEN
        nPeriodo := (TRUNC(v_fcarant) - trunc(to_date(cFechaingresopoliza,'DD/MM/RRRR')));
        nFactor  := nPeriodo / 365;
      ELSE
          nPeriodo       := ABS((dFEFECTO)  - TRUNC(dFVENCIM)); 
          nDiasCobrar  := ABS(trunc(to_date(cFechaingresopoliza,'DD/MM/RRRR')) - TRUNC(dFVENCIM));
      END IF;*/
      -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo

        -- INICIO - 19/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        /* Para los calculos del factor de dias a liquidar en la prima se toma como referencia el fcarant de la caratula,
        cuando no se ha renovado o esta null, el v_fcarant toma el fcarpro. 
        se hacen las restas entre las fechas y para la liquidacion normal se calcula la diferencia de dias dividida entre
        360 para el prorrateo se calculan las fechas restantes con respecto a la fecha de vencimiento de la caratula y se
        divide en 365.

        Despues de renovar para el calculo del factor a liquidar despues del recibo se toma como referencia la fecha de
        la cartera actual.

        */
        v_fvenccar      := dFVENCIM;

        --v_ffinrec       := v_fcarant;

        -- INICIO - 19/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        v_fvenccar      := dFVENCIM;

        v_fefectocert   := cFechaingresopoliza;

        SELECT fcarant 
        INTO v_fcarantcar 
        FROM SEGUROS
        WHERE npoliza = pnpoliza
        AND ncertif = 0;

        SELECT fcarpro 
        INTO v_fcarprocar 
        FROM SEGUROS
        WHERE npoliza = pnpoliza
        AND ncertif = 0;

        SELECT EXTRACT(MONTH FROM LAST_DAY(v_fcarprocar)) 
        INTO v_mesfcarprocar
        FROM dual;

        SELECT EXTRACT(MONTH FROM LAST_DAY(v_fefectocert)) 
        INTO v_mesfefectocert 
        FROM dual;

        SELECT TRUNC(v_fefectocert,'MM') 
        INTO v_primdiamesfefecto
        FROM DUAL;

        -- 365 O 366 si el anio es bisiesto
        SELECT ADD_MONTHS(TO_DATE('0101' || EXTRACT(YEAR FROM LAST_DAY(dFEFECTO)), 'ddmmyyyy'), 12) 
        - TO_DATE('0101' || EXTRACT(YEAR FROM LAST_DAY(dFEFECTO)), 'ddmmyyyy') 
        INTO v_diasanio
        FROM DUAL;

        -- Periodicidad mensual cforpag= 12
        IF xcforpag_rec = 12 THEN
          -- No se ha renovado aun
          IF v_fcarantcar IS NULL THEN
            v_difdias       := v_fcarant - v_fefectocert;

            SELECT EXTRACT(MONTH FROM LAST_DAY(v_fefectocert)) 
            INTO v_mesfefecto 
            FROM dual;

            -- Meses de 30 dias: abril, junio, septiembre y noviembre
            IF v_mesfefecto IN (4,6,9,11) AND ( v_difdias = 30 ) THEN
              v_noprorrat := TRUE;

            -- Meses de 31 dias: enero, marzo, mayo, julio, agosto, octubre, diciembre 
            ELSIF v_mesfefecto IN (1,3,5,7,8,10,12) AND ( v_difdias = 31 ) THEN
              v_noprorrat := TRUE;

            -- Febrero (28-29 dias)
            ELSIF (v_mesfefecto = 2) AND v_difdias IN (28,29) THEN
              v_noprorrat := TRUE;

            END IF;

            -- No hay prorrata
            IF v_noprorrat = TRUE THEN
              v_facnet        := 30 / 360;
              v_facdev        := 1;

            -- Se aplica prorrateo
            ELSE
              nerror          := f_difdata(v_fefectocert, v_fcarant, 1, 3, v_difdiasval);
              nerror          := f_difdata(v_fefectocert, v_fvenccar, 1, 3, v_difdiasanu); --v_fvenccar - v_fefectocert;

              v_facnet        := v_difdiasval / 365;
              v_facdev        := v_difdiasanu / 365;

            END IF;
          -- Ya se renovo
          ELSE



            -- Fecha efecto certificado es igual a la fecha de efecto caratula
            IF v_fefectocert = dFEFECTO THEN
              v_peradic := v_mesfcarprocar - v_mesfefectocert;
              v_difdias := 0;

              -- Se calcula el factor para liquidar la prima
              v_facnet        := ( (30 * v_peradic)/ 360 ) + ( v_difdias/360 );
              v_facdev        := 1;

            ELSE
              v_difdias := v_fcarprocar - v_fefectocert;
              v_difdias := MOD(v_difdias,30);
              v_peradic := f_round(v_difdias/30, null);

              nerror          := f_difdata(v_fefectocert, LAST_DAY(v_fefectocert) + 1, 1, 3, v_difdiasval);
              nerror          := f_difdata(v_fefectocert, v_fvenccar, 1, 3, v_difdiasanu); --v_fvenccar - v_fefectocert;

              v_facnet :=  ( (30 * v_peradic)/ 360 ) + ( v_difdiasval/365 );
              v_facdev :=  ( (30 * v_peradic)/ 360 ) + ( v_difdiasanu/365 );

            END IF;

          END IF;
        -- Periodicidad trimestral cforpag= 4
        ELSIF xcforpag_rec = 4 THEN

          -- No se ha renovado aun
          IF v_fcarantcar IS NULL THEN

            v_difdias       := v_fcarant - v_fefectocert;

            IF v_fefectocert = dFEFECTO THEN
              -- INICIO - 07/04/2021 - Company - Ar 38673 - Inconsistencia valor recibos prima trimestral
              --v_facnet        :=  v_difdias/ 360;
              v_facnet        :=  90/ 360;
              -- FIN - 07/04/2021 - Company - Ar 38673 - Inconsistencia valor recibos prima trimestral
              v_facdev        := 1;

            -- Se aplica prorrateo
            ELSE
              nerror          := f_difdata(v_fefectocert, v_fcarant, 1, 3, v_difdiasval);
              nerror          := f_difdata(v_fefectocert, v_fvenccar, 1, 3, v_difdiasanu);

              v_facnet        := v_difdiasval / 365;
              v_facdev        := v_difdiasanu / 365;

            END IF;
          -- Ya se renovo
          ELSE

            -- Fecha efecto certificado es igual a la fecha de efecto caratula
            IF v_fefectocert = dFEFECTO THEN

              v_peradic := (v_mesfcarprocar - v_mesfefectocert) / 3;
              v_difdias := 0;

              -- Se calcula el factor para liquidar la prima
              v_facnet        := ( (90 * v_peradic)/ 360 ) + ( v_difdias/360 );
              v_facdev        := 1;

            ELSE
              v_difdias := v_fcarprocar - v_fefectocert;

              v_difdias := MOD(v_difdias,90);

              v_peradic := f_round(v_difdias/90, null);

              nerror          := f_difdata(v_fefectocert, (v_primdiamesfefecto + 90), 1, 3, v_difdiasval);

              nerror          := f_difdata(v_fefectocert, v_fvenccar, 1, 3, v_difdiasanu);

              v_facnet :=  ( (90 * v_peradic)/ 360 ) + ( v_difdiasval/365 );

              v_facdev :=  ( (90 * v_peradic)/ 360 ) + ( v_difdiasanu/365 );

            END IF;

          END IF;

        -- Periodicidad semestral cforpag= 2
        ELSIF xcforpag_rec = 2 THEN

          -- No se ha renovado aun
          IF v_fcarantcar IS NULL THEN

            v_difdias       := v_fcarant - v_fefectocert;

            IF v_fefectocert = dFEFECTO THEN
              v_facnet        :=  180/ 360;
              v_facdev        := 1;

            -- Se aplica prorrateo
            ELSE
              nerror          := f_difdata(v_fefectocert, v_fcarant, 1, 3, v_difdiasval);
              nerror          := f_difdata(v_fefectocert, v_fvenccar, 1, 3, v_difdiasanu);

              v_facnet        := v_difdiasval / 365;
              v_facdev        := v_difdiasanu / 365;

            END IF;
          -- Ya se renovo
          ELSE

            -- Fecha efecto certificado es igual a la fecha de efecto caratula
            IF v_fefectocert = dFEFECTO THEN

              v_peradic := f_round( ((v_fcarprocar - v_fefectocert) / 180),null);
              v_difdias := 0;

              -- Se calcula el factor para liquidar la prima
              v_facnet        := ( (180 * v_peradic)/ 360 ) + ( v_difdias/360 );
              v_facdev        := 1;

            ELSE
              v_difdias := v_fcarprocar - v_fefectocert;

              v_peradic := trunc(v_difdias/180);

              nerror          := f_difdata(v_fefectocert, last_day(v_primdiamesfefecto + 180), 1, 3, v_difdiasval);

              nerror          := f_difdata(v_fefectocert, v_fvenccar, 1, 3, v_difdiasanu);

              v_facnet :=  ( (180 * v_peradic)/ 360 ) + ( v_difdiasval/365 );

              v_facdev :=  ( (180 * v_peradic)/ 360 ) + ( v_difdiasanu/365 );

            END IF;

          END IF;

        -- Periodicidad anual cforpag= 1
        ELSIF xcforpag_rec = 1 THEN

          -- No se ha renovado aun
          IF v_fcarantcar IS NULL THEN
            v_difdias       := v_fcarant - v_fefectocert;

            -- No hay prorrata
            IF v_difdias = v_diasanio THEN
              v_facnet        := 1;
              v_facdev        := 1;
            -- Se aplica prorrateo
            ELSE
              nerror          := f_difdata(v_fefectocert, v_fcarant, 1, 3, v_difdiasval);
              nerror          := f_difdata(v_fefectocert, v_fvenccar, 1, 3, v_difdiasanu); --v_fvenccar - v_fefectocert;

              v_facnet        := v_difdiasval / v_diasanio;
              v_facdev        := v_difdiasanu / v_diasanio;

            END IF;
          -- Ya se renovo
          ELSE
            -- Fecha efecto certificado es igual a la fecha de efecto caratula
            IF v_fefectocert = dFEFECTO THEN

              SELECT EXTRACT(YEAR FROM LAST_DAY(v_fcarprocar)) 
              INTO v_aniofcarprocar
              FROM dual;

              SELECT EXTRACT(YEAR FROM LAST_DAY(v_fefectocert)) 
              INTO v_aniofefectocert
              FROM dual;

              v_peradic := v_aniofcarprocar - v_aniofefectocert;
              v_difdias := 0;

              -- Se calcula el factor para liquidar la prima
              v_facnet        := ( (360 * v_peradic)/ 360 ) + ( v_difdias/360 );
              v_facdev        := 1;

            ELSE
              v_difdias := v_fcarprocar - v_fefectocert;
              v_difdias := MOD(v_difdias,30);
              v_peradic := f_round(v_difdias/30, null);

              nerror          := f_difdata(v_fefectocert, LAST_DAY(v_fefectocert) + 1, 1, 3, v_difdiasval);
              nerror          := f_difdata(v_fefectocert, v_fvenccar, 1, 3, v_difdiasanu); --v_fvenccar - v_fefectocert;

              v_facnet :=  ( (360 * v_peradic)/ 360 ) + ( v_difdiasval/v_diasanio );
              v_facdev :=  ( (360 * v_peradic)/ 360 ) + ( v_difdiasanu/v_diasanio );

            END IF;

          END IF;

        END IF; -- XFORPAC_REC
        -- FIN - 19/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo

p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '7477 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
      -- INICIO - 19/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      FOR y IN(SELECT 
                 G.IPRIANU IPRIANU,
                 G.CGARANT, 
                 G.nriesgo, 
                 G.nmovimi
               FROM GARANSEG G
              WHERE G.SSEGURO = psseguro
                AND   G.nmovimi = 1
                AND   G.NRIESGO = 1) LOOP

        v_prifacnet := f_round(y.iprianu * v_facnet,null);
        v_prifacdev := f_round(y.iprianu * v_facdev,null);

        -- Prima Neta (Concepto 0)
        v_concep := f_round((v_prifacnet * NVL(v_coapos,1)),NULL);

        -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
        --num_err := f_insdetrec(num_recibo,0,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,NULL,NULL,NULL,0);
        num_err := f_insdetrec(num_recibo,0,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,v_concep,sysdate,NULL,0);
        IF num_err <> 0 THEN
          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR F_INSDETRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
        END IF;
        -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo

        -- Comision Bruta (Concepto 11)
        v_concep := f_round((v_concep * v_comisi),NULL);

        -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
        --num_err := f_insdetrec(num_recibo,11,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,NULL,NULL,NULL,0);
        num_err := f_insdetrec(num_recibo,11,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,v_concep,sysdate,NULL,0);
        IF num_err <> 0 THEN
          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR F_INSDETRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
        END IF;
        -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
        
        -- Prima Devengada (Concepto 21)
        v_concep := f_round((v_prifacdev * v_coapos),NULL);
        -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
        --num_err := f_insdetrec(num_recibo,21,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,NULL,NULL,NULL,0);
        num_err := f_insdetrec(num_recibo,21,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,v_concep,sysdate,NULL,0);
        IF num_err <> 0 THEN
          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR F_INSDETRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
        END IF;
        -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo

        -- Comision Devengada (Concepto 15)
        v_concep := f_round((v_prifacdev * v_comisi * v_coapos),NULL);
        BEGIN
        INSERT INTO detrecibos(nrecibo, cconcep, cgarant, nriesgo,iconcep,cageven,nmovima,iconcep_monpol,fcambio)
             VALUES (num_recibo, 15, y.cgarant, cPlan,v_concep, null, 1, v_concep, f_sysdate);
        COMMIT;
        END;

        IF NVL(v_coapos,0) < 1 THEN
          -- Prima Neta Cedido (Concepto 50)
          v_concep := f_round((v_prifacnet * v_coacedido),NULL);
          -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
          --num_err := f_insdetrec(num_recibo,50,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,NULL,NULL,NULL,0);
          num_err := f_insdetrec(num_recibo,50,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,v_concep,sysdate,NULL,0);
          IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR F_INSDETRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
          END IF;
          -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
          
          -- Comision Bruta Cedido (Concepto 61)
          v_concep := f_round((v_concep * v_comisi),NULL);
          -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
          --num_err := f_insdetrec(num_recibo,61,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,NULL,NULL,NULL,0);
          num_err := f_insdetrec(num_recibo,61,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,v_concep,sysdate,NULL,0);
          IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR F_INSDETRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
          END IF;
          -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
          
          -- Comision Devengada Cedido (Concepto 65)
          v_concep := f_round((v_prifacdev * v_comisi * v_coacedido),NULL);
          -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
          --num_err := f_insdetrec(num_recibo,65,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,NULL,NULL,NULL,0);
          num_err := f_insdetrec(num_recibo,65,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,v_concep,sysdate,NULL,0);
          IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR F_INSDETRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
          END IF;
          -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo

          -- Prima Devengada Cedido (Concepto 71)
          v_concep := f_round((v_prifacdev * v_coacedido),NULL);
          -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
          --num_err := f_insdetrec(num_recibo,71,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,NULL,NULL,NULL,0);
          num_err := f_insdetrec(num_recibo,71,v_concep,NULL,y.CGARANT,cPlan,NULL,NULL,1,0,psseguro,1,v_concep,sysdate,NULL,0);
          IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR F_INSDETRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
          END IF;
          -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo

        END IF;
      END LOOP;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '7575 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
      SELECT ROUND(SUM(ICONCEP))
       INTO TOTALPRIMA
       FROM DETRECIBOS
       WHERE NRECIBO = num_recibo
       AND CCONCEP IN (0,50);
      -- FIN - 19/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo

--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB            
/*
    FOR y IN(SELECT              
             --- INICIO PYALLTIT  06062020
             -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
             --ROUND((( (G.IPRIANU/xcforpag_rec) / nPeriodo) * nDiasCobrar),2) IPRIANU,--ROUND(((G.IPRIANU / nPeriodo) * nDiasCobrar),2) IPRIANU, --  G.IPRIANU,
              G.IPRIANU IPRIANU,
             -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
             -- G.IPRIANU / NVL(xcforpag_rec,1) IPRIANU,
             --- FIN PYALLTIT  06062020
             G.CGARANT, G.nriesgo, G.nmovimi
             FROM GARANSEG G
             WHERE G.SSEGURO =  psseguro
             AND   G.nmovimi = 1
             AND   G.NRIESGO = 1) LOOP --STM : NRIESGO = P_NPLAN STMR
--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB     
             BEGIN
        -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        IF TRUNC(dFEFECTO) <> Trunc(to_date(cFechaingresopoliza,'DD/MM/RRRR')) THEN 
          v_iprianu := ROUND((y.iprianu * nFactor),2);
        ELSE
          v_iprianu := ROUND((( (y.iprianu/xcforpag_rec) / nPeriodo) * nDiasCobrar),2);
        END IF;
        -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      --  INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
                 num_err := f_insdetrec(num_recibo, --pnrecibo,
                                    0,
                                    Y.IPRIANU,
                                    NULL, --xploccoa,
                                    Y.CGARANT, 
                                    1,
                                    NULL, --xctipcoa,
                                    NULL, --xcageven_gar,
                                    1, --xnmovima_gar,
                                    0, --xccomisi,
                                    PSSEGUROASEG,
                                    1,
                                    NULL,
                                    NULL,
                                    NULL,
                                    0 --decimals
                                    );
      IF v_coapos > 0 THEN
        -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        --v_concep := y.iprianu * (v_coacedido /100);
        v_concep := v_iprianu * v_coapos;
      ELSE 
        --v_concep := y.iprianu;
        v_concep := v_iprianu; 
        -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      END IF;
      -- Prima Neta (Concepto 0)

      num_err := f_insdetrec(num_recibo, --pnrecibo,
                             0,
                             v_concep,
                             NULL, --xploccoa,
                             y.CGARANT, 
                             cPlan,
                             NULL, --xctipcoa,
                             NULL, --xcageven_gar,
                             1, --xnmovima_gar,
                             0, --xccomisi,
                             psseguro,
                             1,
                             NULL,
                             NULL,
                             NULL,
                             0 --decimals
                             );

      IF num_err <> 0 THEN
        RETURN num_err;
      END IF;
      -- Prima Neta Cedido (Concepto 50)
      -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      --v_concep := y.iprianu * ( (100 - v_coacedido) /100);
      v_concep := v_iprianu *  v_coacedido;
      --v_concep := trunc(v_concep);

      -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      IF v_coacedido > 0 THEN

        num_err := f_insdetrec(num_recibo, --pnrecibo,
                               50,
                               v_concep,
                               NULL, --xploccoa,
                               y.CGARANT, 
                               cPlan,
                               NULL, --xctipcoa,
                               NULL, --xcageven_gar,
                               1, --xnmovima_gar,
                               0, --xccomisi,
                               psseguro,
                               1,
                               NULL,
                               NULL,
                               NULL,
                               0 --decimals
                              );
        IF num_err <> 0 THEN
          RETURN num_err;
        END IF;
      END IF;
      IF v_comisi > 0 THEN
        --v_concep_cb := v_concep * (v_comisi /100);
        IF v_coapos > 0 THEN
        -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        --v_concep := y.iprianu * (v_coacedido /100);
        v_concep := v_iprianu * v_coapos;
        v_concep_cb := v_concep * v_comisi;
        ELSE
        -- v_concep_cb := y.iprianu * (v_comisi /100);
        v_concep_cb := v_iprianu * v_comisi;
        -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        END IF;
        -- Comision Bruta (Concepto 11)
        num_err := f_insdetrec(num_recibo, --pnrecibo,
                               11,
                               v_concep_cb,
                               NULL, --xploccoa,
                               y.CGARANT,
                               cPlan,
                               NULL, --xctipcoa,
                               NULL, --xcageven_gar,
                               1, --xnmovima_gar,
                               0, --xccomisi,
                               psseguro,
                               1,
                               NULL,
                               NULL,
                               NULL,
                               0 --decimals
                               ); 
        IF num_err <> 0 THEN
          RETURN num_err;
        END IF;
      END IF;
      IF v_coacedido > 0 AND v_comisi > 0 THEN
        -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        --v_concep := y.iprianu * ( (100 - v_coacedido) /100);
        v_concep := v_iprianu * v_coacedido;
        -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        v_concep_cb := v_concep * v_comisi;
        -- Comision Bruta - Cedido (Concepto 61)
        num_err := f_insdetrec(num_recibo, --pnrecibo,
                               61,
                               v_concep_cb,
                               NULL, --xploccoa,
                               y.CGARANT, 
                               cPlan,
                               NULL, --xctipcoa,
                               NULL, --xcageven_gar,
                               1, --xnmovima_gar,
                               0, --xccomisi,
                               psseguro,
                               1,
                               NULL,
                               NULL,
                               NULL,
                               0 --decimals
                               ); 
        IF num_err <> 0 THEN
          RETURN num_err;
        END IF;
      END IF;
      --  FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
      -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      TOTALPRIMA :=      ROUND(TOTALPRIMA     + y.IPRIANU); 
      -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
     EXCEPTION
       WHEN OTHERS THEN
             nExisteError := 1;
             nSqlerrm     := Sqlerrm;
             nSqlCode     := SqlCode;
             cObservaTrz  := 'Insert Datos de Detalle Recibos(2): Error '||nSqlCode||' '||nSqlerrm;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT DETRECIBOS 3 cObservaTrz = ' || cObservaTrz, SQLERRM);
        END;
            IF nExisteError = 0 THEN
               cObservaTrz  := 'Insert Datos de Detalle Recibos(2): '||psseguro||' lncertif: '||lncertif||' Y.CGARANT: '||Y.CGARANT||' pnpoliza: '||pnpoliza||' '||cObservaTrz;
            END IF;                       
     END LOOP; 
     */
     --  INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
    /*
    FOR y IN (SELECT 
               -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
               --ROUND((( (G.IPRIANU/xcforpag_rec) / nPeriodo) * nDiasCobrar),2) IPRIANU,--ROUND(((G.IPRIANU / nPeriodo) * nDiasCobrar),2) IPRIANU,
               G.IPRIANU IPRIANU,
               --G.IPRIANU PRIMAANUAL,
               -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
               G.CGARANT, G.nriesgo, G.nmovimi
               FROM GARANSEG G
               WHERE G.SSEGURO = (select sseguro from seguros where npoliza = pnpoliza AND ncertif = 0)
               -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
               --AND   G.nmovimi = 1
               AND   G.nmovimi = (SELECT MAX(NMOVIMI) FROM GARANSEG WHERE SSEGURO = (select sseguro from seguros where npoliza = pnpoliza AND ncertif = 0) )
               -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
               AND   G.NRIESGO = cPlan) LOOP
       BEGIN
         -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
         IF TRUNC(dFEFECTO) <> Trunc(to_date(cFechaingresopoliza,'DD/MM/RRRR')) THEN 
           v_iprianu := ROUND((y.iprianu * nFactor),2);
         ELSE
           --v_iprianu := ROUND((( (y.iprianu/xcforpag_rec) / nPeriodo) * nDiasCobrar),2);
           v_iprianu := y.iprianu;
         END IF;
         --IF v_coacedido > 0 AND v_comisi > 0 THEN
         IF v_comisi > 0 THEN
           IF v_coapos > 0 THEN
         -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
           -- Comision Devengada (Concepto 15)
           -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
           -- v_coadev   :=  y.iprianu * ( ( v_coacedido) /100);
           v_coadev   :=  v_iprianu * v_coapos;
           -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
           v_comdev   := v_coadev * v_comisi;
           -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
           ELSE
             -- v_comdev   := y.iprianu * (v_comisi/100);
             v_comdev   := v_iprianu * v_comisi;
           END IF;
           -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
           BEGIN
           INSERT INTO detrecibos
                              (nrecibo, cconcep, cgarant, nriesgo,
                               iconcep)
                       VALUES (num_recibo, 15, y.cgarant, cPlan,
                               v_comdev);
           EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT DETRECIBOS 4 cObservaTrz = ' || cObservaTrz, SQLERRM);
           END;
           -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
           IF v_coacedido > 0 THEN
           --v_coadev   :=  y.iprianu * ( (100 - v_coacedido) /100);
           v_coadev   :=  v_iprianu * ( v_coacedido /100);
           -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
           v_comdev   := v_coadev * v_comisi;
           -- Comision Devengada - Cedido (Concepto 65)
           num_err := f_insdetrec(num_recibo, --pnrecibo,
                                  65,
                                  v_comdev,
                                  NULL, --xploccoa,
                                  y.CGARANT,
                                  cPlan,
                                  NULL, --xctipcoa,
                                  NULL, --xcageven_gar,
                                  1, --xnmovima_gar,
                                  0, --xccomisi,
                                  psseguro,
                                  1,
                                  NULL,
                                  NULL,
                                  NULL,
                                  0 --decimals
                                  );
           IF num_err <> 0 THEN
             RETURN num_err;
           END IF;
           -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
           END IF;
           -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
         END IF;
         IF v_coacedido > 0 THEN
           -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
           --v_coadev   :=  y.iprianu * ( (100 - v_coacedido) /100);
           v_coadev   :=  v_iprianu * ( v_coacedido /100);
           -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
           -- Prima Devengada Cedido (Concepto 71)
           num_err := f_insdetrec(num_recibo, --pnrecibo,
                                  71,
                                  v_coadev,
                                  NULL, --xploccoa,
                                  y.CGARANT,
                                  cPlan,
                                  NULL, --xctipcoa,
                                  NULL, --xcageven_gar,
                                  1, --xnmovima_gar,
                                  0, --xccomisi,
                                  psseguro,
                                  1,
                                  NULL,
                                  NULL,
                                  NULL,
                                  0 --decimals
                                  ); 
         END IF;
         -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
         IF v_coapos > 0 THEN
         -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
         --v_coadev   :=  y.iprianu * ( ( v_coacedido) /100);
         v_coadev   :=  v_iprianu * v_coapos;
         -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
         ELSE
         -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
         --v_coadev   :=  y.iprianu;
         v_coadev   :=  v_iprianu;
         END IF;
         -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
         -- Prima Devengada (Concepto 21)
         num_err := f_insdetrec(num_recibo, --pnrecibo,
                               21,
                               v_coadev,
                               NULL, --xploccoa,
                               y.CGARANT,
                               cPlan,
                               NULL, --xctipcoa,
                               NULL, --xcageven_gar,
                               1, --xnmovima_gar,
                               0, --xccomisi,
                               psseguro,
                               1,
                               NULL,
                               NULL,
                               NULL,
                               0 --decimals
                               );
           IF num_err <> 0 THEN
             RETURN num_err;
           END IF;
       COMMIT;
       -- INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
       --TOTALPRIMA :=      TOTALPRIMA     + y.IPRIANU;
       --  FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
      EXCEPTION
       WHEN OTHERS THEN
             nExisteError := 1;
             nSqlerrm     := Sqlerrm;
             nSqlCode     := SqlCode;
             cObservaTrz  := 'Insert Datos de Detalle Recibos: Error '||nSqlCode||' '||nSqlerrm;
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT DETRECIBOS 4 cObservaTrz = ' || cObservaTrz, SQLERRM);
        END;
    END LOOP;
    */
    -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
    /*nExisteError := f_vdetrecibos ('R', num_recibo);
    IF nExisteError > 0 THEN
      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT VDETRECIBOS 2 nExisteError = ' || nExisteError, SQLERRM);
    END IF;*/

       BEGIN
       Insert into VDETRECIBOS (NRECIBO,IPRINET,IRECEXT,ICONSOR,IRECCON,IIPS,IDGS,IARBITR,IFNG,IRECFRA,IDTOTEC,IDTOCOM,ICOMBRU,
       ICOMRET,IDTOOM,IPRIDEV,ITOTPRI,ITOTDTO,ITOTCON,ITOTIMP,ITOTALR,IDERREG,ITOTREC,ICOMDEV,IRETDEV,ICEDNET,ICEDREX,ICEDCON,
       ICEDRCO,ICEDIPS,ICEDDGS,ICEDARB,ICEDFNG,ICEDRFR,ICEDDTE,ICEDDCO,ICEDCBR,ICEDCRT,ICEDDOM,ICEDPDV,ICEDREG,ICEDCDV,ICEDRDV,
       IT1PRI,IT1DTO,IT1CON,IT1IMP,IT1REC,IT1TOTR,IT2PRI,IT2DTO,IT2CON,IT2IMP,IT2REC,IT2TOTR,ICOMCIA,ICOMBRUI,ICOMRETI,ICOMDEVI,
       ICOMDRTI,ICOMBRUC,ICOMRETC,ICOMDEVC,ICOMDRTC,IOCOREC,IIMP_1,IIMP_2,IIMP_3,IIMP_4,ICONVOLEODUCTO) 
       values (num_recibo,TOTALPRIMA,'0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMA,TOTALPRIMA,'0','0','0',TOTALPRIMA,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMA,'0','0','0','0',TOTALPRIMA,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');
       EXCEPTION
         WHEN OTHERS THEN
           nExisteError := 1;
           p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT VDETRECIBOS ', SQLERRM);
       END;
       BEGIN
       Insert into VDETRECIBOS_MONPOL (NRECIBO,IPRINET,IRECEXT,ICONSOR,IRECCON,IIPS,IDGS,IARBITR,IFNG,IRECFRA,IDTOTEC,IDTOCOM,
       ICOMBRU,ICOMRET,IDTOOM,IPRIDEV,ITOTPRI,ITOTDTO,ITOTCON,ITOTIMP,ITOTALR,IDERREG,ITOTREC,ICOMDEV,IRETDEV,ICEDNET,ICEDREX,
       ICEDCON,ICEDRCO,ICEDIPS,ICEDDGS,ICEDARB,ICEDFNG,ICEDRFR,ICEDDTE,ICEDDCO,ICEDCBR,ICEDCRT,ICEDDOM,ICEDPDV,ICEDREG,ICEDCDV,
       ICEDRDV,IT1PRI,IT1DTO,IT1CON,IT1IMP,IT1REC,IT1TOTR,IT2PRI,IT2DTO,IT2CON,IT2IMP,IT2REC,IT2TOTR,ICOMCIA,ICOMBRUI,ICOMRETI,
       ICOMDEVI,ICOMDRTI,ICOMBRUC,ICOMRETC,ICOMDEVC,ICOMDRTC,IOCOREC,IIMP_1,IIMP_2,IIMP_3,IIMP_4,ICONVOLEODUCTO) 
       values (num_recibo,TOTALPRIMA,'0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMA,TOTALPRIMA,'0','0','0',TOTALPRIMA,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMA,'0','0','0','0',TOTALPRIMA,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');
       EXCEPTION
         WHEN OTHERS THEN
           nExisteError := 1;
           p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT VDETRECIBOS_MONPOL ', SQLERRM);
       END;

p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '7949 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
    --  FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
       --- INICIO PYALLTIT  17072020                                     
       IF pac_retorno.f_tiene_retorno(NULL, psseguro, NULL, 'SEG') = 1 THEN
          -- v_numerr := f_generar_retorno_pos(pnpoliza,psseguro, NVL(pcmovimi, lnmovimi), NULL,NULL);
         v_numerr2 := f_generar_retorno_pos(pnpoliza,psseguro, NULL, NULL,NULL);
       COMMIT;
       END IF;
   --- FIN PYALLTIT  17072020				 
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '7958 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
   END IF;
   -- INICIO - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
   /* BEGIN
    INSERT INTO MSV_TB_CARGUE_MASIVO_TRZ
    (ID, ID_CARGUE, NRO_LINEA, TEXTO, ESTADO, OBSERVACIONES, 
           USUARIO_CREACION, FECHA_CREACION, USUARIO_MODIFICACION, FECHA_MODIFICACION)
    SELECT ID, ID_CARGUE, NRO_LINEA, TEXTO, ESTADO, cObservaTrz, 
           USER, SYSDATE, USER, SYSDATE
    FROM MSV_TB_CARGUE_MASIVO_DET
    WHERE ID        = p_id_cargue_in
    AND   ID_CARGUE = p_id_cargue_in;

     COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('30 MSV_TB_CARGUE_MASIVO_TRZ**psseguro****==>>>>  '||psseguro 
    || ' p_id_cargue_in ' ||p_id_cargue_in||' '||SQLERRM||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    END;*/
    -- FIN - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
     -- FIN PYALLTIT
         pcestado := 2;   -- Dades basiques gravades
--------------------------------------------------------------------------
-- Primer commit, ja tenim les dades basiques de la polisa, actualitzem
-- l'estat del registre, i la emission va be fa commit i si no rollback
-- quan tornem a cridar al proc haure continuar per aqui         
         BEGIN
            UPDATE carrega_col
               SET cestado = 2,
                   sseguro = psseguro
             WHERE sproces = psproces
               AND nlinea = pnlinea;
            COMMIT;   ---
         EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF',1,'EXCEPCION UPDATE carrega_col cestado 2 SQLERRM: ' || Sqlerrm, Sqlerrm);
              RETURN 140714;
         END;
      END IF;   -- Fi de l'estat = 1
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '7997 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
      IF pcestado = 2
         OR pcestado = 3 THEN   -- Dades basiques gravades (polisa no emesa)
         IF piapoini_promo IS NOT NULL THEN
            IF pcestado = 2 THEN
               IF lnmovimi IS NULL THEN
                  lnmovimi := 1;
               END IF;
               BEGIN
                 INSERT INTO garanseg
                             (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden, crevali,
                             ctarifa, icapital, iprianu, ipritar, prevali, itarifa, itarrea,
                             ipritot, icaptot, ftarifa, nmovima)
                      VALUES (282, 1, lnmovimi, psseguro, pfefecto, l282.norden, l282.crevali,
                            l282.ctarifa, piapoini_promo, 0, 0, l282.prevali, 0, 0,
                            0, piapoini_promo, pfefecto, 1);
               EXCEPTION
                 WHEN OTHERS THEN
                   p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF',1,'EXCEPCION INSERT GARANSEG SQLERRM: ' || Sqlerrm, Sqlerrm);
               END;
               p_emitir_propuesta(pcempres, pnpoliza, lncertif, pcramo, pcmodali, pctipseg,
                                  pccolect, pcactivi, pmoneda, pcidioma, lindice, lindice_e,
                                  lindice_t, pmensaje,   -- BUG 27642 - FAL - 30/04/2014
                                  psproces, NVL(lnorden_promo, 1));
               IF lindice_e <> 0 THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF',1,'ERROR P_EMITIR_PROPUESTA pnpoliza: ' || pnpoliza || ' lncertif: ' || lncertif || ' lindice_e: ' || lindice_e, Sqlerrm);
                  RETURN 140730;
               END IF;
--------------------------------------------------------
-- Si ha anat be, tenim la proposta emesa, cestado = 3
-- actualitzem l'estat de la linea
               BEGIN
                  UPDATE carrega_col
                     SET cestado = 3
                   WHERE sproces = psproces
                     AND nlinea = pnlinea;
                  COMMIT;   ---
               EXCEPTION
                  WHEN OTHERS THEN
                    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF',1,'EXCEPCION UPDATE carrega_col cestado 3 SQLERRM: ' || Sqlerrm, Sqlerrm);
                    RETURN 140714;
               END;

               pcestado := 3;
            END IF;
            -- cestado = 3 anem a cobrar el rebut
            IF pcestado = 3 THEN
               IF pcobrar = 1 THEN
                  IF lnmovimi IS NULL THEN
                     lnmovimi := 1;
                  END IF;

                  IF lccobban IS NULL THEN
                     SELECT ccobban
                       INTO lccobban
                       FROM seguros
                      WHERE sseguro = psseguro;
                  END IF;
                  -- Cobrar el rebut
                  SELECT MAX(nrecibo)
                    INTO lnrecibo
                    FROM recibos
                   WHERE sseguro = psseguro
                     AND nmovimi = lnmovimi;
                  -- Obtenim la delegacion
                  SELECT c01
                    INTO lcdelega
                    FROM seguredcom
                   WHERE sseguro = psseguro
                     AND fmovfin IS NULL;
                  IF pfefecto > f_sysdate THEN
                     lfmovini := pfefecto;
                  ELSE
                     lfmovini := f_sysdate;
                  END IF;
                  num_err := f_movrecibo(lnrecibo, 1, lfmovini, NULL, lsmovagr, lnliqmen,
                                         lnliqlin, lfmovini, lccobban, lcdelega, NULL, NULL);
                  IF num_err <> 0 THEN
                    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF',1,'ERROR F_MOVRECIBO num_err: ' || num_err, Sqlerrm);
                    RETURN num_err;
                  END IF;
                  IF lprod.cagrpro = 11 THEN
                     SELECT MAX(nnumlin)
                       INTO llinea
                       FROM ctaseguro
                      WHERE sseguro = psseguro;
                     ldivisa := 3;
                     lnparpla := f_valor_participlan(pfefecto, psseguro, ldivisa);
                     IF lnparpla <> -1 THEN
                        lparticipacion := ROUND((piapoini_promo / lnparpla), 6);
                        UPDATE ctaseguro
                           SET nparpla = lparticipacion,
                               cestpar = 1
                         WHERE sseguro = psseguro
                           AND nnumlin = llinea;
                     END IF;
                  END IF;
--------------------------------------------------------
-- Si ha anat be, tenim el primer rebut cobrat, cestado = 4
-- actualitzem l'estat de la linea
                  BEGIN
                     UPDATE carrega_col
                        SET cestado = 4
                      WHERE sproces = psproces
                        AND nlinea = pnlinea;
                     COMMIT;   ---
                  EXCEPTION
                     WHEN OTHERS THEN
                       p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF',1,'EXCEPCION UPDATE carrega_col cestado 4 SQLERRM: ' || Sqlerrm, Sqlerrm);
                       RETURN 140714;
                  END;
                  pcestado := 4;
               ELSE
                  -- si no es cobren, l'estat passa directament a 4,
                  --pendent d'emetre el segon moviment
                  pcestado := 4;
               END IF;
            END IF;
         ELSE
            -- si no hi ha aport. inicial de promotor,l'estat passa directament a 4,
            --pendent d'emetre el segon moviment
            pcestado := 4;
         END IF;
      END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '8121 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
-----------------------------------------------------------------------
-- tractament de l'aportacion l'assegurat
-----------------------------------------------------------------------
-- Obtenim dades parcials dels estats anteriors
      IF lnmovimi IS NULL THEN
         SELECT MAX(nmovimi), MAX(nsuplem) + 1
           INTO lnmovimi, lnsuplem
           FROM movseguro
          WHERE sseguro = psseguro;
      END IF;
      IF lncertif IS NULL
         OR lccobban IS NULL THEN
         SELECT ncertif, ccobban
           INTO lncertif, lccobban
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;
      IF lcdelega IS NULL THEN
         -- Obtenim la delegacion
         SELECT c01
           INTO lcdelega
           FROM seguredcom
          WHERE sseguro = psseguro
            AND fmovfin IS NULL;
      END IF;
      IF pcestado = 4
         OR pcestado = 5
         OR pcestado = 6 THEN
         IF piapoini_asseg IS NOT NULL THEN
            IF pcestado = 4 THEN
               IF piapoini_promo IS NOT NULL THEN
                  -- Cal generar un moviment d'extra per el segon aportant
                  num_err := f_act_hisseg(psseguro, lnmovimi);
                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
                  UPDATE seguros
                     SET csituac = 5
                   WHERE sseguro = psseguro;

                  num_err := f_movseguro(psseguro, NULL, 500, 1, pfefecto, NULL, lnsuplem, 0,
                                         NULL, lnmovimi, NULL, NULL, NULL, NULL);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
                  lnsuplem := lnsuplem + 1;
                  num_err := f_dupgaran(psseguro, pfefecto, lnmovimi);
                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
--------------------------------------------------------
-- Si ha anat be, tenim el moviment generat, cal emetre cestado = 5
-- actualitzem l'estat de la linea
                  BEGIN
                     UPDATE carrega_col
                        SET cestado = 5
                      WHERE sproces = psproces
                        AND nlinea = pnlinea;
                     COMMIT;   ---
                  EXCEPTION
                     WHEN OTHERS THEN
                       p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 2,'UPDATE CARREGA_COL SET CESTADO 5 SQLERRM: ' || SQLERRM, SQLERRM);
                       RETURN 140714;
                  END;
                  pcestado := 5;
               ELSE
                  -- no cal generar el moviment, cal emetre el de nova produccion
                  pcestado := 5;
               END IF;
            END IF;   -- cestado = 4
            --- cestado = 5, anem a emetre el moviment
            IF pcestado = 5 THEN
              BEGIN
                INSERT INTO garanseg
                            (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden, crevali,
                            ctarifa, icapital, iprianu, ipritar, prevali, itarifa, itarrea,
                            ipritot, icaptot, ftarifa, nmovima)
                     VALUES (282, 1, lnmovimi, psseguro, pfefecto, l282.norden, l282.crevali,
                            l282.ctarifa, piapoini_asseg, 0, 0, l282.prevali, 0, 0,
                            0, piapoini_asseg, pfefecto, 1);
                COMMIT;
              EXCEPTION
                WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 2,'EXCEPTION INSERT GARANSEG SQLERRM: ' || SQLERRM, SQLERRM);
              END;
               IF lnorden_asseg IS NULL THEN
                  lnorden_asseg := lnmovimi;
               END IF;
               p_emitir_propuesta(pcempres, pnpoliza, lncertif, pcramo, pcmodali, pctipseg,
                                  pccolect, pcactivi, pmoneda, pcidioma, lindice, lindice_e,
                                  lindice_t, pmensaje,   -- BUG 27642 - FAL - 30/04/2014
                                  psproces, lnorden_asseg);

               IF lindice_e <> 0 THEN
                 p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF',1,'ERROR P_EMITIR_PROPUESTA pnpoliza: ' || pnpoliza || ' lncertif: ' || lncertif || ' lindice_e: ' || lindice_e, Sqlerrm);
                 RETURN 140730;
               END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '8220 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
--------------------------------------------------------
-- Si ha anat be, tenim la proposta emesa, cestado = 6
-- actualitzem l'estat de la linea
               BEGIN
                 UPDATE carrega_col
                    SET cestado = 6
                  WHERE sproces = psproces
                    AND nlinea = pnlinea;
                COMMIT;
               EXCEPTION
                 WHEN OTHERS THEN
                   p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 2,'UPDATE CARREGA_COL SET CESTADO 6 SQLERRM: ' || SQLERRM, SQLERRM);
                   RETURN 140714;
               END;
               pcestado := 6;
            END IF;
            IF pcestado = 6 THEN
               IF pcobrar = 1 THEN
                  -- Cobrar el rebut
                  SELECT MAX(nrecibo)
                    INTO lnrecibo
                    FROM recibos
                   WHERE sseguro = psseguro
                     AND nmovimi = lnmovimi;
                  IF pfefecto > f_sysdate THEN
                     lfmovini := pfefecto;
                  ELSE
                     lfmovini := f_sysdate;
                  END IF;
                  num_err := f_movrecibo(lnrecibo, 1, lfmovini, NULL, lsmovagr, lnliqmen,
                                         lnliqlin, lfmovini, lccobban, lcdelega, NULL, NULL);
                  IF num_err <> 0 THEN
                     p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF',1,'ERROR f_movrecibo lnrecibo: ' || lnrecibo || ' num_err: ' || num_err, Sqlerrm);
                     RETURN num_err;
                  END IF;
                  IF lprod.cagrpro = 11 THEN
                     SELECT MAX(nnumlin)
                       INTO llinea
                       FROM ctaseguro
                      WHERE sseguro = psseguro;
                     ldivisa := 3;
                     lnparpla := f_valor_participlan(pfefecto, psseguro, ldivisa);
                     IF lnparpla <> -1 THEN
                        lparticipacion := ROUND((piapoini_asseg / lnparpla), 6);
                        UPDATE ctaseguro
                           SET nparpla = lparticipacion,
                               cestpar = 1
                         WHERE sseguro = psseguro
                           AND nnumlin = llinea;
                     END IF;
                  END IF;
--------------------------------------------------------
-- Si ha anat be, tenim el segon rebut cobrat, cestado = 7
-- actualitzem l'estat de la linea
                  BEGIN
                     UPDATE carrega_col
                        SET cestado = 7
                      WHERE sproces = psproces
                        AND nlinea = pnlinea;
                     COMMIT;   ---
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 140714;
                  END;
                  pcestado := 7;
               ELSE
                  pcestado := 7;
               END IF;
            END IF;
         ELSE
            -- si no hi ha aport. asseg, l'estat passa a pendent de generar la peria
            pcestado := 7;
         END IF;
      END IF;
      --
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '8296 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
      -- Obtenim dades parcials dels estats anteriors
      IF lnmovimi IS NULL THEN
         SELECT MAX(nmovimi), MAX(nsuplem) + 1
           INTO lnmovimi, lnsuplem
           FROM movseguro
          WHERE sseguro = psseguro;
      END IF;
      IF pcestado = 7 THEN
         IF piprianu IS NOT NULL THEN
            -- Fer moviment d'inici d'aportacio, ja es genera emision
            num_err := f_act_hisseg(psseguro, lnmovimi);
            UPDATE seguros
               SET cforpag = GREATEST(NVL(pcforpag_promo, 0), NVL(pcforpag_asseg, 0)),
                   fcarpro = LEAST(NVL(pfcarpro_promo, '31/12/2999'),
                                   NVL(pfcarpro_asseg, '31/12/2999')),
                   fcaranu = ADD_MONTHS(LEAST(NVL(pfcarpro_promo, '31/12/2999'),
                                              NVL(pfcarpro_asseg, '31/12/2999')),
                                        12)
             WHERE sseguro = psseguro;

            num_err := f_movseguro(psseguro, NULL, 252, 1, pfefecto, NULL, lnsuplem, 0, NULL,
                                   lnmovimi, f_sysdate, NULL, NULL, NULL);

            lnsuplem := lnsuplem + 1;
            num_err := f_dupgaran(psseguro, pfefecto, lnmovimi);
            INSERT INTO garanseg
                        (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden, crevali,
                         ctarifa, icapital, iprianu, ipritar, prevali, itarifa, itarrea,
                         ipritot, icaptot, ftarifa, nmovima)
                 VALUES (48, 1, lnmovimi, psseguro, pfefecto, l48.norden, l48.crevali,
                         l48.ctarifa, 0, piprianu, piprianu, l48.prevali, 0, 0,
                         piprianu, 0, pfefecto, lnmovimi);
--------------------------------------------------------
-- Si ha anat be, el moviment de canvi de periodo cestado = 8
-- actualitzem l'estat de la linea
            BEGIN
               UPDATE carrega_col
                  SET cestado = 8
                WHERE sproces = psproces
                  AND nlinea = pnlinea;
               COMMIT;   ---
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 140714;
            END;

            pcestado := 8;
         ELSE
            pcestado := 8;
         END IF;
      END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 111, '8348 F_ALTA_CERTIF SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
      RETURN 0;
   EXCEPTION
     WHEN OTHERS THEN
       p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 2,'Error f_alta_certif.: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
       -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
       -- RETURN 9999;
       RETURN 1;
       -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
   END f_alta_certif;
--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB   
FUNCTION f_baja_certif(pnpoliza IN NUMBER, p_id_cargue_in IN NUMBER,p_TIPO IN NUMBER,p_NUMID IN VARCHAR2, P_NLINEA IN NUMBER, P_NPLAN IN NUMBER,P_RECIBO IN NUMBER) RETURN NUMBER IS
-------------------------------------------------------------------------------------
      pcempres NUMBER;
      vsproduc NUMBER;
      pfefecto DATE;
      psproces NUMBER;
      pnlinea NUMBER;
      pcestado NUMBER;
      pcramo NUMBER;
      pcmodali NUMBER;
      pctipseg NUMBER;
      pccolect NUMBER;
      psperson_promo NUMBER;
      psperson_asseg NUMBER;
      pcbancar_promo VARCHAR2(1000);
      pcbancar_asseg VARCHAR2(1000);
      pcdomici_promo NUMBER;
      pcdomici_asseg NUMBER;
      piapoini_promo NUMBER;
      piapoini_asseg NUMBER;
      piprianu NUMBER;
      papor_promo NUMBER;
      piapor_promo NUMBER;
      pfcarpro_promo DATE;
      pfcarpro_asseg DATE;
      pcforpag_promo NUMBER;
      pcforpag_asseg NUMBER;
      pcrevali NUMBER;
      pprevali NUMBER;
      pfrevali DATE;
      ptbenef1 VARCHAR2(1000);
      ptbenef2 VARCHAR2(1000);
      ptbenef3 VARCHAR2(1000);
      ppolissa_ini NUMBER;
      pcidioma NUMBER;
      pcoficin NUMBER;
      pfvencim DATE;
      pcactivi NUMBER;
      num_recibo NUMBER;
      ptnatrie VARCHAR2(1000);
      pmoneda NUMBER(14);
      pcfiscal_promo NUMBER(14);
      pcfiscal_asseg NUMBER(14);
      ppimport_promo NUMBER(14);
      ppimport_asseg NUMBER(14);
      piimport_promo NUMBER(14);
      piimport_asseg NUMBER(14);
      pcobrar NUMBER(14);
      psseguro NUMBER(14);
        nExistePer        NUMBER;
        nExisteAseg       NUMBER;
        PSSEGUROASEG      NUMBER;
        NSPERSON          NUMBER;
        cPOLIZA           VARCHAR2(4000);
        cPrimerNombre     VARCHAR2(4000);	
        cSegundoNombre    VARCHAR2(4000);	
        cPrimerApellido   VARCHAR2(4000);
        cSegundoApellido  VARCHAR2(4000);
        cTipoIdentificacion        VARCHAR2(4000);	
        cNumeroIdentificacion      VARCHAR2(4000);	
        cGenero                    VARCHAR2(4000);	
        cFechaNacimiento           VARCHAR2(4000);	
        cFechaingresopoliza        VARCHAR2(4000);
        cPlan                      VARCHAR2(4000);
        cCodigo                    VARCHAR2(4000);	
        cCursoSede                 VARCHAR2(4000);
-------------------------------------------------------------------------------------
        cCorreoelectronico         VARCHAR2(4000);
        cFechaefectoNovedad        DATE;
        cCausaanulacion            VARCHAR2(4000);	
        cmtvoanulacion             VARCHAR2(4000);
        cTipodeNovedad             VARCHAR2(4000);
        vsseguro                   NUMBER;
        VNCERTIF                    NUMBER;
        TVALORDEX                  VARCHAR2(4000);

        exnum_err        NUMBER;
        vctx             NUMBER;
        mensajes         t_iax_mensajes;
        pnmovimi         NUMBER;
        vcagente         NUMBER;

        ffecextini       DATE:= sysdate; 
        ffecextfin       DATE:= sysdate;
        vcctiprec        NUMBER := 9;
        v_tipocert       VARCHAR2(20);
        num_err          NUMBER;
        nnrecibo         NUMBER;
        NRNRECIBO       NUMBER ;
        TOTALPRIMAEX      NUMBER ;
        --- INICIO PYALLTIT 06062020
        xcforpag_rec      NUMBER;
        dFVENCIM          DATE;
        nDiasDevolver     NUMBER;
        nPeriodo          NUMBER;
        dFEFECTO          DATE;
        --- FIN PYALLTIT
        --- INICIO PYALLTIT  17072020   
        v_numerr2  NUMBER;
        --- FIN PYALLTIT  17072020  								 
        --  INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
        v_ctipcom         NUMBER;
        v_iprianu         NUMBER;
        v_concep          NUMBER;
        v_coacedido       NUMBER;
        v_tienecoaseg     NUMBER;
        v_sseguro_0       NUMBER;
        v_comisi          NUMBER;
        v_cforpag         NUMBER;
        v_concep_cb       NUMBER;
        v_coadev          NUMBER; 
        v_comdev          NUMBER;
        v_porcprim        NUMBER;
        nSqlerrm          VARCHAR2(4000);
        nSqlCode          NUMBER;
        cObservaTrz       VARCHAR2(4000);
        nExisteError      NUMBER;
        nPlan             NUMBER;
        --  FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
        v_fcarpro         DATE;
        -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        v_nfactor         NUMBER;
        v_fefecto         DATE;
        v_primnet         NUMBER;
        v_coapos          NUMBER := 0;
        v_fcarant         DATE;
        -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
  BEGIN

   --- INICIO PYALLTIT  06062020
   BEGIN
    -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
    --SELECT DECODE(CFORPAG,0,1,CFORPAG),FVENCIM,FEFECTO, FCARPRO, FCARANT
    SELECT DECODE(CFORPAG,0,1,CFORPAG),FVENCIM,FEFECTO, FCARPRO, NVL(FCARANT,FCARPRO)
    INTO   xcforpag_rec, dFVENCIM,dFEFECTO, v_fcarpro, v_fcarant
    -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
    FROM   SEGUROS S 
    WHERE S.NPOLIZA = pnpoliza
    AND   S.NCERTIF = 0;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
          xcforpag_rec :=0; dFVENCIM := NULL;
    END;    
   --- FIN PYALLTIT  06062020

        BEGIN
        SELECT DISTINCT CAMPO01,CAMPO10,CAMPO15,CAMPO17
        INTO cPOLIZA,cFechaefectoNovedad, cCausaanulacion ,cmtvoanulacion 
        FROM INT_CARGA_GENERICO
        WHERE PROCESO   = p_id_cargue_in
        AND   NCARGA    =  p_id_cargue_in
        AND   TIPO_OPER = 'AS'
        AND   NLINEA    = P_NLINEA;        
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
           cCorreoelectronico := null;  cFechaefectoNovedad := null;  cCausaanulacion := null;  cmtvoanulacion := null;  cTipodeNovedad := null; 	cCursoSede := null; 
        END;

     BEGIN
        SELECT s.sseguro ,S.NCERTIF , S.CAGENTE
        INTO vsseguro , VNCERTIF , vcagente
        FROM seguros s 
        WHERE s.npoliza = cPOLIZA 
        AND s.ncertif <>0 
        AND EXISTS (select 1 
                 from asegurados a 
                where a.sseguro = s.sseguro
                  and a.sperson in(select  p.sperson 
                                     from per_personas p 
                                    where p.nnumide = p_NUMID 
                                      and ctipide = p_TIPO));
    EXCEPTION WHEN OTHERS THEN
      vsseguro := NULL;
    END;
      -- INICIO - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
        v_ncertif := VNCERTIF;
      --- INICIO PYALLTIT  06062020
      /* BEGIN

        -- TVALORDEX :=  pnpoliza||'-'||VNCERTIF;
        TVALORDEX :=  VNCERTIF;
        TVALORDFEX := TVALORDFEX||';'||TVALORDEX;  
       END;*/
      --- FIN PYALLTIT  06062020
      -- FIN - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
      BEGIN

      SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(17, 'USER_BBDD')) INTO VCTX FROM DUAL; 

      /*
       f_anulaseg
       psseguro IN NUMBER,
       pcanuext IN NUMBER,
       pfanulac IN DATE,
       pcmotmov IN NUMBER,
       pnrecibo IN NUMBER,
       pcsituac IN NUMBER,
       pnmovimi OUT NUMBER,
       pcnotibaja IN NUMBER DEFAULT NULL,
       pmoneda IN NUMBER DEFAULT 1,
       psproces IN NUMBER DEFAULT NULL,
       pccauanul IN NUMBER DEFAULT NULL,
       pcmotanul IN NUMBER DEFAULT NULL)
      */

      -- MOTIVO : select * from motmovseg where cidioma = 8;
      -- CAUSA : select * from detvalores where cvalor = 61;
        exnum_err :=  f_anulaseg(vsseguro, 0, 
                                 trunc(to_date(cFechaefectoNovedad,'DD/MM/RRRR')),
                                 --- INICIO PYALLTIT  06062020
                                 cmtvoanulacion, -- 503, 
                                 --- FIN PYALLTIT  06062020
                                 NULL, 
                                 2, 
                                 pnmovimi);--cmtvoanulacion : 503 , cCausaanulacion : 2 cFechaefectoNovedad
       -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
       IF TO_DATE(cFechaefectoNovedad,'DD/MM/RR') >= TO_DATE(v_fcarant,'DD/MM/RR') THEN
         v_fcarant := v_fcarpro;
       END IF;
       -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
       -- INSERTA EL RECIBO DE EXTORNO POR ASEGURADO EN CERTIFICADO
       num_err := f_insrecibo(Vsseguro, vcagente, f_sysdate, 
                                         --- INICIO PYALLTIT  06062020
                                         trunc(to_date(cFechaefectoNovedad,'DD/MM/RRRR')), -- ffecextini,
                                          v_fcarant,
                                          --dFVENCIM, -- 
                                         -- ffecextfin, 
                                         --- FIN PYALLTIT  06062020 
                                         vcctiprec, NULL, NULL, NULL, NULL,NULL, 
                                         nnrecibo, 'R', NULL, NULL, pnmovimi,f_sysdate, 
                                         v_tipocert
                                       --  ,xcforpag_rec -- --- INICIO PYALLTIT  06062020
                                         );                                    
       IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.f_baja_certif',1,'ERROR F_INSRECIBO num_err: ' || num_err, nSqlerrm);
         RETURN num_err;
       END IF;
       -- INICIO - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP
       BEGIN
         INSERT INTO msv_recibos(id_cargue,proceso,recibo,estado)
              VALUES(v_idcargue, v_sproces, nnrecibo, 0);
       EXCEPTION
         WHEN OTHERS THEN
           p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR INSERT MSV_RECIBOS ', SQLERRM);
       END;
       -- FIN - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP
      BEGIN 
        Insert into adm_recunif (NRECIBO,NRECUNIF,SDOMUNIF) values (nnrecibo,P_RECIBO,null);
        COMMIT;
      EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_BAJA_CERTIF',1,'EXCEPCION INSERT ADM_RECUNIF: ' || nSqlerrm, nSqlerrm);
      END;

      BEGIN 
        SELECT count(NRECIBO)
        INTO NRNRECIBO
        from MOVRECIBO where NRECIBO = nnrecibo;
      EXCEPTION
        WHEN OTHERS THEN
          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_BAJA_CERTIF',1,'EXCEPCION SELECT MOVRECIBO: ' || nSqlerrm, nSqlerrm);
      END;

      IF NRNRECIBO = 0 THEN
      SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(17, 'USER_BBDD')) INTO vctx FROM dual; 
      BEGIN
      Insert into MOVRECIBO (SMOVREC,NRECIBO,CUSUARI,SMOVAGR,CESTREC,CESTANT,
                       FMOVINI,
                       FMOVFIN,
                       FCONTAB,FMOVDIA,
                       CMOTMOV,CCOBBAN,CDELEGA,CTIPCOB,FEFEADM,CGESCOB,TMOTMOV) 
            values ((SELECT MAX(SMOVREC) + 1  FROM MOVRECIBO),nnrecibo,F_USER,'5231881','0','0',
                    trunc(to_date(cFechaefectoNovedad,'DD/MM/RRRR')), -- to_date(SYSDATE,'DD/MM/RRRR'),
                    dFVENCIM, -- 
                   -- null,
                    to_date(SYSDATE,'DD/MM/RRRR'),to_date(SYSDATE,'DD/MM/RRRR'),null,null,'40',
                    null,to_date(SYSDATE,'DD/MM/RRRR'),null,null);
      COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          nExisteError := 1;
          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_BAJA_CERTIF', 1, 'EXCEPCION INSERT MOVRECIBO ', SQLERRM);
      END;
      END IF;

      BEGIN
        UPDATE RECIBOS SET CESTAUX = 2 WHERE SSEGURO IN (VSSEGURO);
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_BAJA_CERTIF', 1, 'EXCEPCION UPDATE RECIBOS CESTAUX SQLERRM = ' || SQLERRM, SQLERRM);
      END;

      --  INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
      BEGIN
        SELECT sseguro, ctipcom
        INTO v_sseguro_0, v_ctipcom 
        FROM seguros WHERE npoliza = pnpoliza AND ncertif = 0;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      -- Se obtiene el porcentaje de comision
      v_comisi := PAC_ENVIO_PRODUCCION_COL.F_PRI_COMISION(v_sseguro_0,1,num_recibo,v_ctipcom);
      v_comisi := (nvl(v_comisi,2) / 100);
      -- Se obtiene el porcentaje de coaseguro
      /*
      BEGIN
        SELECT ploccoa
          INTO v_coapos
          FROM coacuadro
          WHERE sseguro = v_sseguro_0
          AND ncuacoa = (SELECT MAX(ncuacoa) FROM coacedido WHERE sseguro = v_sseguro_0);
      EXCEPTION
        WHEN OTHERS THEN
          v_coapos := 0;
      END;
      v_coapos := (nvl(v_coapos,0) / 100);
      */
      BEGIN
        SELECT sum(pcescoa)
          INTO v_coacedido
          FROM coacedido
          WHERE sseguro = v_sseguro_0
          AND ncuacoa = (SELECT MAX(ncuacoa) FROM coacedido WHERE sseguro = v_sseguro_0);
      EXCEPTION
        WHEN OTHERS THEN
          v_coacedido := 0;
      END;
          v_coacedido := (NVL(v_coacedido,0) / 100);
            -- Obtiene el numero del riesgo

      IF NVL(v_coacedido,0) > 0 THEN
        v_coapos := 1 - v_coacedido;
      END IF;

      BEGIN
        SELECT crespue
        INTO nPlan
        FROM pregunpolseg
        WHERE cpregun=4089
        AND sseguro = vsseguro
        AND nmovimi = (select max(nmovimi) from pregunpolseg where sseguro = Vsseguro);
      EXCEPTION
        WHEN OTHERS THEN
          nPlan := 1;
      END;
      --  FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
      --- INICIO PYALLTIT  06062020
        -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        --nPeriodo       := ABS((dFEFECTO)  - TRUNC(dFVENCIM));
        BEGIN
          SELECT cforpag
          INTO v_cforpag
          FROM seguros 
          WHERE sseguro = v_sseguro_0;
        EXCEPTION
          WHEN OTHERS THEN
            v_cforpag:= 1;
        END;
        /*IF v_cforpag = 1 THEN --ANUAL
          nPeriodo := 365;
        ELSIF v_cforpag = 2 THEN -- SEMESTRAL
          nPeriodo := 180;
        ELSIF v_cforpag = 4 THEN -- TRIMESTRAL
          nPeriodo := 90;
        ELSIF v_cforpag = 6 THEN -- BIMENSUAL
          nPeriodo := 60;
        ELSIF v_cforpag = 3 THEN -- CUATRIMESTRAL
          nPeriodo := 120;
        ELSIF v_cforpag = 12 THEN -- MENSUAL
          nPeriodo := 30;
        END IF;
        nDiasDevolver  := ABS(365 - (  TRUNC(dFVENCIM) - trunc(to_date(cFechaefectoNovedad,'DD/MM/RRRR')) ));*/
        -- Se aplica el calculo de iaxis normal (pac_anulacion.f_extorn_rec_cobrats): (rcob(i).fvencim - pfanulac) /(rcob(i).fvencim - rcob(i).fefecto)
        BEGIN
          SELECT fefecto
          INTO  v_fefecto
          FROM seguros
          -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
          --WHERE sseguro = Vsseguro;
          WHERE sseguro = vsseguro;
          -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        EXCEPTION
          WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_BAJA_CERTIF',1,'EXCEPCION SELECT FROM SEGUROS ', Sqlerrm);
        END;
        -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        v_nfactor := (v_fcarant - cFechaefectoNovedad)/(v_fcarant - v_fefecto);

        -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        /*
        IF nDiasDevolver = 365 THEN
          nDiasDevolver := 0;
        END IF;
        */
        -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      --- FIN PYALLTIT  06062020   
      --
      TOTALPRIMAEX := 0 ;
      --
      -- INICIO - 19/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      FOR y IN (SELECT f_round((iconcep * v_nfactor),null) IPRIANU,
                      cconcep,
                      cgarant,
                      nriesgo,
                      nmovima
               FROM DETRECIBOS
                      WHERE nrecibo = (SELECT nrecibo FROM recibos WHERE sseguro = vsseguro AND ctiprec = 0)
                      ) LOOP
        BEGIN
           INSERT INTO detrecibos(nrecibo, cconcep, cgarant, nriesgo,iconcep,cageven,nmovima,iconcep_monpol,fcambio)
                VALUES (nnrecibo, y.cconcep, y.cgarant, cPlan,y.iprianu, null, 1, y.iprianu, f_sysdate);
           EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_BAJA_CERTIF',1,'EXCEPCION INSERT DETRECIBOS SQLERRM: ' || Sqlerrm, Sqlerrm);
        END;

        IF Y.CCONCEP IN (0,50) THEN 
          TOTALPRIMAEX :=  TOTALPRIMAEX  + y.IPRIANU;
        END IF;
      END LOOP;
      -- FIN - 19/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo

      /*
    FOR y IN(SELECT 
                  -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
                  (G.IPRIANU/v_cforpag) * v_nfactor IPRIANU,
                  --(G.IPRIANU /v_cforpag ) - ROUND((( (G.IPRIANU/ v_cforpag)/nPeriodo ) * nDiasDevolver ),2) IPRIANU, -- ROUND((( (G.IPRIANU) / nPeriodo) * nDiasDevolver),2)  IPRIANU, --SELECT ROUND(((G.IPRIANU / nPeriodo) * nDiasDevolver),2)  IPRIANU, 
                  -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
                   G.CGARANT, G.nriesgo, G.nmovimi
             FROM GARANSEG G
             WHERE G.SSEGURO =  vsseguro
             AND   G.nmovimi = 1
             -- INICIO - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
             --AND   G.NRIESGO = nPlan) LOOP --STM : NRIESGO = P_NPLAN STMR
             AND   G.NRIESGO = 1) LOOP --STM : NRIESGO = P_NPLAN STMR
             -- FIN - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB
     */
     /*
     FOR y IN (SELECT (iconcep * v_nfactor) IPRIANU,
                      cgarant,
                      nriesgo,
                      nmovima
               FROM DETRECIBOS
                      WHERE nrecibo = (SELECT nrecibo FROM recibos WHERE sseguro = vsseguro AND ctiprec = 0)
                      --AND cconcep in (0,50)
                      ) LOOP
     -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      BEGIN

      --  INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
      IF NVL(v_coapos,0) > 0 THEN
        v_concep := y.iprianu * v_coapos;

      ELSE 
        v_concep := y.iprianu;

      END IF;

      -- Prima Neta (Concepto 0)
      num_err := f_insdetrec(nnrecibo, --pnrecibo,
                             0,
                             v_concep,
                             NULL, --xploccoa,
                             y.CGARANT, 
                             nPlan,
                             NULL, --xctipcoa,
                             NULL, --xcageven_gar,
                             1, --xnmovima_gar,
                             0, --xccomisi,
                             psseguro,
                             1,
                             NULL,
                             NULL,
                             NULL,
                             0 --decimals
                             );

      IF num_err <> 0 THEN
        RETURN num_err;
      END IF;
      -- Prima Neta Cedido (Concepto 50)
      v_concep := y.iprianu * v_coacedido;
      --v_concep := trunc(v_concep);

      IF v_coacedido > 0 THEN
        num_err := f_insdetrec(nnrecibo, --pnrecibo,
                               50,
                               v_concep,
                               NULL, --xploccoa,
                               y.CGARANT,
                               nPlan,
                               NULL, --xctipcoa,
                               NULL, --xcageven_gar,
                               1, --xnmovima_gar,
                               0, --xccomisi,
                               psseguro,
                               1,
                               NULL,
                               NULL,
                               NULL,
                               0 --decimals
                              );
        IF num_err <> 0 THEN
          RETURN num_err;
        END IF;
      END IF;
      IF v_comisi > 0 THEN
        --v_concep_cb := v_concep * (v_comisi /100);
        IF v_coapos > 0 THEN
        v_concep := y.iprianu * v_coapos;
        v_concep_cb := v_concep * v_comisi;

        ELSE
        v_concep_cb := y.iprianu * v_comisi;

        END IF;

        -- Comision Bruta (Concepto 11)
        num_err := f_insdetrec(nnrecibo, --pnrecibo,
                               11,
                               v_concep_cb,
                               NULL, --xploccoa,
                               y.CGARANT,
                               nPlan,
                               NULL, --xctipcoa,
                               NULL, --xcageven_gar,
                               1, --xnmovima_gar,
                               0, --xccomisi,
                               psseguro,
                               1,
                               NULL,
                               NULL,
                               NULL,
                               0 --decimals
                               ); 
        IF num_err <> 0 THEN
          RETURN num_err;
        END IF;
      END IF;
      IF v_coacedido > 0 AND v_comisi > 0 THEN
        v_concep := y.iprianu * v_coacedido ;
        v_concep_cb := v_concep * v_comisi;

        -- Comision Bruta - Cedido (Concepto 61)
        num_err := f_insdetrec(nnrecibo, --pnrecibo,
                               61,
                               v_concep_cb,
                               NULL, --xploccoa,
                               y.CGARANT,
                               nPlan,
                               NULL, --xctipcoa,
                               NULL, --xcageven_gar,
                               1, --xnmovima_gar,
                               0, --xccomisi,
                               psseguro,
                               1,
                               NULL,
                               NULL,
                               NULL,
                               0 --decimals
                               ); 
        IF num_err <> 0 THEN
          RETURN num_err;
        END IF;
      END IF;
      --  FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
            -- INICIO - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
            --TOTALPRIMAEX :=    ROUND(  TOTALPRIMAEX     + y.IPRIANU);  
            TOTALPRIMAEX :=  TOTALPRIMAEX  + y.IPRIANU;  
            -- FIN - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
       COMMIT;
      EXCEPTION
       WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION INSERT DETRECIBOS SQLERRM: ' || Sqlerrm, Sqlerrm);
        END;
    END LOOP;
    */
    --  INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
    -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
    /*
    FOR y IN (SELECT 
               -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
               (G.IPRIANU/v_cforpag) * v_nfactor IPRIANU,
               --ROUND((G.IPRIANU /v_cforpag ) - ROUND((( (G.IPRIANU/ v_cforpag)/nPeriodo ) * nDiasDevolver ),2),2) IPRIANU,--ROUND((( (G.IPRIANU) / nPeriodo) * nDiasDevolver),2) IPRIANU,--ROUND(((G.IPRIANU / nPeriodo) * nDiasDevolver),2) IPRIANU,
               -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
               G.IPRIANU PRIMAANUAL,
               G.CGARANT, G.nriesgo, G.nmovimi
               FROM GARANSEG G
               WHERE G.SSEGURO = (select sseguro from seguros where npoliza = pnpoliza AND ncertif = 0)
               AND   G.nmovimi = 1
               -- INICIO - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
               -- AND   G.NRIESGO = nPlan) LOOP
               AND   G.NRIESGO = 1) LOOP
               -- FIN - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
      */


      /*
           FOR y IN (SELECT (iconcep * v_nfactor) IPRIANU,
                      cgarant,
                      nriesgo,
                      nmovima
               FROM DETRECIBOS
                      WHERE nrecibo = (SELECT nrecibo FROM recibos WHERE sseguro = vsseguro AND ctiprec = 0)
                      AND cconcep IN (0,50)) LOOP
       -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
       BEGIN

         IF v_coapos > 0 AND v_comisi > 0 THEN
           -- Comision Devengada (Concepto 15)
           v_coadev   :=  y.iprianu * v_coapos;
           v_comdev   := v_coadev * v_comisi;

           BEGIN
           INSERT INTO detrecibos
                       -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
                              --(nrecibo, cconcep, cgarant, nriesgo,iconcep)
                              (nrecibo, cconcep, cgarant, nriesgo,iconcep,cageven,nmovima,iconcep_monpol,fcambio)
                       --VALUES (nnrecibo, 15, y.cgarant, cPlan,v_comdev);
                       VALUES (nnrecibo, 15, y.cgarant, cPlan,v_comdev, null, 1, v_comdev, f_sysdate);
                       -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
           EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_BAJA_CERTIF',1,'EXCEPCION INSERT DETRECIBOS CONCEPTO 15 SQLERRM: ' || Sqlerrm, Sqlerrm);
           END;
           v_coadev   :=  y.iprianu * v_coacedido;
           v_comdev   := v_coadev * v_comisi;

           -- Comision Devengada - Cedido (Concepto 65)
           num_err := f_insdetrec(nnrecibo, --pnrecibo,
                                  65,
                                  v_comdev,
                                  NULL, --xploccoa,
                                  y.CGARANT, 
                                  nPlan,
                                  NULL, --xctipcoa,
                                  NULL, --xcageven_gar,
                                  1, --xnmovima_gar,
                                  0, --xccomisi,
                                  psseguro,
                                  1,
                                  NULL,
                                  NULL,
                                  NULL,
                                  0 --decimals
                                  );
           IF num_err <> 0 THEN
             RETURN num_err;
           END IF;
         END IF;
         IF v_coacedido > 0 THEN
           v_coadev   :=  y.iprianu * v_coacedido;

           -- Prima Devengada Cedido (Concepto 71)
           num_err := f_insdetrec(nnrecibo, --pnrecibo,
                                  71,
                                  v_coadev,
                                  NULL, --xploccoa,
                                  y.CGARANT, 
                                  nPlan,
                                  NULL, --xctipcoa,
                                  NULL, --xcageven_gar,
                                  1, --xnmovima_gar,
                                  0, --xccomisi,
                                  psseguro,
                                  1,
                                  NULL,
                                  NULL,
                                  NULL,
                                  0 --decimals
                                  ); 
         END IF;
         v_coadev   :=  y.iprianu * v_coapos;

         -- Prima Devengada (Concepto 21)
         num_err := f_insdetrec(nnrecibo, --pnrecibo,
                               21,
                               v_coadev,
                               NULL, --xploccoa,
                               y.CGARANT, 
                               nPlan,
                               NULL, --xctipcoa,
                               NULL, --xcageven_gar,
                               1, --xnmovima_gar,
                               0, --xccomisi,
                               psseguro,
                               1,
                               NULL,
                               NULL,
                               NULL,
                               0 --decimals
                               );
           IF num_err <> 0 THEN
             RETURN num_err;
           END IF;
       COMMIT;
       -- INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
       --TOTALPRIMA :=      TOTALPRIMA     + y.IPRIANU;
       --  FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
      EXCEPTION
       WHEN OTHERS THEN
             nExisteError := 1;
             nSqlerrm     := Sqlerrm;
             nSqlCode     := SqlCode;
             cObservaTrz  := 'Insert Datos de Detalle Recibos: Error '||nSqlCode||' '||nSqlerrm||' '||cObservaTrz;
        END;
    END LOOP;

    */
    --  FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017

   --- INICIO PYALLTIT  17072020                                     
    IF pac_retorno.f_tiene_retorno(NULL, vsseguro, NULL, 'SEG') = 1 THEN
      -- v_numerr := f_generar_retorno_pos(pnpoliza,psseguro, NVL(pcmovimi, lnmovimi), NULL,NULL);

     v_numerr2 := f_generar_retorno_recob(pnpoliza,vsseguro, NULL, NULL,NULL);
    COMMIT;
   END IF;
   --- FIN PYALLTIT  17072020					
     TOTALPRIMAEX := ROUND(TOTALPRIMAEX);
     BEGIN

       Insert into VDETRECIBOS (NRECIBO,IPRINET,IRECEXT,ICONSOR,IRECCON,IIPS,IDGS,IARBITR,IFNG,IRECFRA,IDTOTEC,IDTOCOM,ICOMBRU,
       ICOMRET,IDTOOM,IPRIDEV,ITOTPRI,ITOTDTO,ITOTCON,ITOTIMP,ITOTALR,IDERREG,ITOTREC,ICOMDEV,IRETDEV,ICEDNET,ICEDREX,ICEDCON,
       ICEDRCO,ICEDIPS,ICEDDGS,ICEDARB,ICEDFNG,ICEDRFR,ICEDDTE,ICEDDCO,ICEDCBR,ICEDCRT,ICEDDOM,ICEDPDV,ICEDREG,ICEDCDV,ICEDRDV,
       IT1PRI,IT1DTO,IT1CON,IT1IMP,IT1REC,IT1TOTR,IT2PRI,IT2DTO,IT2CON,IT2IMP,IT2REC,IT2TOTR,ICOMCIA,ICOMBRUI,ICOMRETI,ICOMDEVI,
       ICOMDRTI,ICOMBRUC,ICOMRETC,ICOMDEVC,ICOMDRTC,IOCOREC,IIMP_1,IIMP_2,IIMP_3,IIMP_4,ICONVOLEODUCTO) 
       values (nnrecibo,TOTALPRIMAEX,'0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMAEX,TOTALPRIMAEX,'0','0','0',TOTALPRIMAEX,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMAEX,'0','0','0','0',TOTALPRIMAEX,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');
       COMMIT;
     EXCEPTION
       WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_BAJA_CERTIF', 1, 'EXCEPCION INSERT VDETRECIBOS SQLERRM = ' || SQLERRM, SQLERRM);
     END;
     BEGIN
       Insert into VDETRECIBOS_MONPOL (NRECIBO,IPRINET,IRECEXT,ICONSOR,IRECCON,IIPS,IDGS,IARBITR,IFNG,IRECFRA,IDTOTEC,IDTOCOM,
       ICOMBRU,ICOMRET,IDTOOM,IPRIDEV,ITOTPRI,ITOTDTO,ITOTCON,ITOTIMP,ITOTALR,IDERREG,ITOTREC,ICOMDEV,IRETDEV,ICEDNET,ICEDREX,
       ICEDCON,ICEDRCO,ICEDIPS,ICEDDGS,ICEDARB,ICEDFNG,ICEDRFR,ICEDDTE,ICEDDCO,ICEDCBR,ICEDCRT,ICEDDOM,ICEDPDV,ICEDREG,ICEDCDV,
       ICEDRDV,IT1PRI,IT1DTO,IT1CON,IT1IMP,IT1REC,IT1TOTR,IT2PRI,IT2DTO,IT2CON,IT2IMP,IT2REC,IT2TOTR,ICOMCIA,ICOMBRUI,ICOMRETI,
       ICOMDEVI,ICOMDRTI,ICOMBRUC,ICOMRETC,ICOMDEVC,ICOMDRTC,IOCOREC,IIMP_1,IIMP_2,IIMP_3,IIMP_4,ICONVOLEODUCTO) 
       values (nnrecibo,TOTALPRIMAEX,'0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMAEX,TOTALPRIMAEX,'0','0','0',TOTALPRIMAEX,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMAEX,'0','0','0','0',TOTALPRIMAEX,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');
       COMMIT;
     EXCEPTION
       WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_BAJA_CERTIF', 1, 'EXCEPCION INSERT VDETRECIBOS_MONPOL SQLERRM = ' || SQLERRM, SQLERRM);
     END;
   EXCEPTION
     WHEN OTHERS THEN
       p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_BAJA_CERTIF', 1, 'EXCEPCION RECIBOS SQLERRM = ' || SQLERRM, SQLERRM);
   END;
   COMMIT;
     RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_BAJA_CERTIF', 2,'Error f_baja_certif.: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, SQLERRM);
        -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
        -- RETURN 9999;
        RETURN 1;
        -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
   END f_baja_certif;

FUNCTION pr_valida_pos(p_id_cargue IN  MSV_TB_CARGUE_MASIVO.id%TYPE ) RETURN NUMBER IS
      pcempres NUMBER;
      vsproduc NUMBER;
      pfefecto DATE;
      psproces NUMBER;
      pnlinea NUMBER;
      pcestado NUMBER;
      pcramo NUMBER;
      pcmodali NUMBER; 
      PRAGMA AUTONOMOUS_TRANSACTION;
  TYPE r_cursor
  IS
    REF
    CURSOR;
      vr_cursor r_cursor;
      vr_cursor_validador r_cursor;
      vr_id_cargue      NUMBER;
      vr_nro_linea      NUMBER;
      vr_texto          VARCHAR2(32000);
      vr_estado         VARCHAR2(10);
      vr_observaciones  VARCHAR2(32000);
      t_tmp_array       pac_msv_utilidades.t_array;
      t_tmp_array_val   pac_msv_utilidades.t_array;
      v_cumple          VARCHAR2(10);
      v_resultado       NUMBER := 0;
      v_conta           NUMBER := 0;
      v_rcermal         NUMBER := 0;
      v_tresult         VARCHAR2(32000) := '';
      v_date            DATE;
      v_poliza          VARCHAR2(100);
      v_seguro          VARCHAR2(100);
      v_cont_plan       NUMBER := 0;
      v_fec_ini         DATE;
      v_fec_fin         DATE;
      v_tipo_doc        NUMBER;
      v_documen_ex      VARCHAR2(100);
      v_tipo_doc_ex     NUMBER;
      v_con_aseg        NUMBER := 0;
      v_con_aseg_pre    NUMBER := 0;
      v_contar          NUMBER := 0;
      v_tipo_doc2       NUMBER;
      nexiste           NUMBER := 0;
      nconta2           NUMBER := 0;
      v_con_plan        NUMBER := 0;
      v_aegurado        NUMBER := 0;
      v_anulado         VARCHAR2(100) := '0';
      v_edad            NUMBER := 0;
      v_vedad           NUMBER := 0;
      v_edadmin         NUMBER := 0;
      v_edadmax         NUMBER := 0;
      -- 7.0 
      nexisteproce      NUMBER := 0;
      v_situac          NUMBER;
      -- 7.0
      -- 9.0
      n_total_registros_cargue NUMBER := 0;
      -- 9.0
      --Ini Company(LARO) 28112020 Factura Electronica
      v_pregun535       NUMBER;
      --Fin Company(LARO) 28112020 Factura Electronica
      -- INICIO - 11/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
      val_numero        NUMBER;
      v_estadepto       NUMBER;
      v_estaciudad      NUMBER;
      -- FIN - 11/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
      validaplanok      BOOLEAN:= TRUE;
      v_traecel         BOOLEAN:= TRUE;
      -- INICIO - 24/03/2021 - Company - Ar 37175
      v_valsperson_t    TOMADORES.SPERSON%TYPE;
      v_valcdomici_t    PER_DIRECCIONES.CDOMICI%TYPE;
      v_valtdomici_t    PER_DIRECCIONES.TDOMICI%TYPE;
      v_valcpoblac_t    PER_DIRECCIONES.CPOBLAC%TYPE;
      v_valcprovin_t    PER_DIRECCIONES.CPROVIN%TYPE;
      v_tvalcontel_t    PER_CONTACTOS.TVALCON%TYPE;
      v_tvalconcel_t    PER_CONTACTOS.TVALCON%TYPE;
      v_tvalconemail_t  PER_CONTACTOS.TVALCON%TYPE;
      -- FIN - 24/03/2021 - Company - Ar 37175
    BEGIN
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '9200 ENTRA A PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
--9.0
    BEGIN
    SELECT COUNT(1)
    INTO n_total_registros_cargue
    FROM MSV_TB_CARGUE_MASIVO_DET
    WHERE  ID_CARGUE = p_id_cargue;
    EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM MSV_TB_CARGUE_MASIVO_DET. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
    END;

--9.0
--6.0
    BEGIN
    UPDATE MSV_TB_CARGUE_MASIVO
    SET ESTADO_CARGUE = pac_msv_constantes.c_estado_cargue_inconsistente
--9.0
    ,TOTAL_REGISTROS = n_total_registros_cargue
--9.0
    WHERE ID = p_id_cargue;
    COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error UPDATE MSV_TB_CARGUE_MASIVO. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
    END;

--6.0
    BEGIN
    SELECT NPOLIZA INTO v_poliza FROM MSV_TB_CARGUE_MASIVO WHERE ID = p_id_cargue;
    EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM MSV_TB_CARGUE_MASIVO. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
    END;

    BEGIN
    SELECT SSEGURO,CSITUAC  INTO v_seguro,v_situac FROM SEGUROS WHERE NPOLIZA = v_poliza AND NCERTIF = 0;
    EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM SEGUROS. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
    END;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '9241 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
    --7.0
    IF v_situac = 5 THEN
        BEGIN
          SELECT 1
          INTO nexisteproce
          FROM SEGUROS
          WHERE SSEGURO = v_seguro
          AND EXISTS (SELECT 1
                         FROM SEGUROS 
                         WHERE NPOLIZA = v_poliza
                         AND  FEMISIO IS NULL );
        EXCEPTION 
        WHEN TOO_MANY_ROWS THEN
          nexisteproce := 1;
        WHEN OTHERS THEN
          nexisteproce := 0;
        END; 
    ELSE
      nexisteproce := 0;
    END IF;
    IF nexisteproce = 1 then 
       vr_observaciones := vr_observaciones ||' Existe emision de certificados en curso para esta caratula, por favor validar.'||  ',';
       v_resultado := v_resultado + 1;
    END IF;
    -- INICIO - 24/03/2021 - Company - Ar 37175
    -- Se obtiene el sperson del tomador
    BEGIN
      SELECT sperson
      INTO v_valsperson_t
      FROM TOMADORES
      WHERE sseguro = v_seguro
      AND nordtom = 1;
    EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'EXCEPCION SELECT FROM SEGUROS ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
    END;
    -- Se obtienen datos de direccion del tomador
    BEGIN
      SELECT cdomici, tdomici, cpoblac, cprovin
      INTO v_valcdomici_t, v_valtdomici_t, v_valcpoblac_t, v_valcprovin_t
      FROM PER_DIRECCIONES
      WHERE sperson = v_valsperson_t
      AND cdomici = 1;
    EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'EXCEPCION SELECT FROM PER_DIRECCIONES ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
    END;
    -- Se obtiene dato de telefono fijo del tomador
    BEGIN
      SELECT tvalcon
      INTO v_tvalcontel_t
      FROM per_contactos
      WHERE sperson = v_valsperson_t
      AND ctipcon = 1
      AND cmodcon = (SELECT MIN(cmodcon) FROM per_contactos WHERE sperson = v_valsperson_t AND ctipcon = 1);
    EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'EXCEPCION SELECT FROM PER_CONTACTOS ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
    END;
    -- Se obtiene dato de telefono movil del tomador
    BEGIN
      SELECT tvalcon
      INTO v_tvalconcel_t
      FROM per_contactos
      WHERE sperson = v_valsperson_t
      AND ctipcon in(5,6)
      AND cmodcon = (SELECT MIN(cmodcon) FROM per_contactos WHERE sperson = v_valsperson_t AND ctipcon IN (5,6));
    EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'EXCEPCION SELECT FROM PER_CONTACTOS ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
    END;
    -- Se obtiene dato de correo electronico del tomador
    BEGIN
      SELECT tvalcon
      INTO v_tvalconemail_t
      FROM per_contactos
      WHERE sperson = v_valsperson_t
      AND ctipcon = 3
      AND cmodcon = (SELECT MIN(cmodcon) FROM per_contactos WHERE sperson = v_valsperson_t AND ctipcon = 3);
   EXCEPTION
     WHEN OTHERS THEN
       p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'EXCEPCION SELECT FROM PER_CONTACTOS ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
   END;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '9325 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
   --p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'8886 ******************* GENERA LA OBSERVACION POR DATOS INCOMPLETOS TOMADOR v_valcdomici_t: ' || v_valcdomici_t || ' v_valtdomici_t: ' || v_valtdomici_t || ' v_valcpoblac_t: ' || v_valcpoblac_t || ' v_valcprovin_t: ' || v_valcprovin_t || ' v_tvalcontel_t: ' || v_tvalcontel_t || ' v_tvalconcel_t: ' || v_tvalconcel_t || ' v_tvalconemail_t: ' || v_tvalconemail_t, SQLERRM);
   IF v_valcdomici_t IS NULL OR v_valtdomici_t IS NULL OR v_valcpoblac_t IS NULL OR v_valcprovin_t IS NULL OR v_tvalcontel_t IS NULL OR v_tvalconcel_t IS NULL OR v_tvalconemail_t IS NULL THEN
     p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'8887 ******************* GENERA LA OBSERVACION POR DATOS INCOMPLETOS TOMADOR ', SQLERRM);
     vr_observaciones := vr_observaciones ||' El tomador tiene datos incompletos.'||  ',';
     v_resultado := v_resultado + 1;
   END IF;
   -- FIN - 24/03/2021 - Company - Ar 37175
    --7.0
    BEGIN
    SELECT TO_CHAR(FEFECTO, 'dd/mm/yyyy')  INTO v_fec_ini FROM SEGUROS WHERE NPOLIZA = v_poliza AND NCERTIF = 0;
    EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM SEGUROS. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
    END;

    BEGIN
    SELECT TO_CHAR(NVL(s.fvencim, s.fcaranu), 'dd/mm/yyyy') ffinpol INTO v_fec_fin
    FROM SEGUROS s WHERE NPOLIZA = v_poliza AND NCERTIF = 0;
    EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM SEGUROS. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
    END;

    BEGIN 
    SELECT COUNT(*) INTO v_con_aseg  FROM MSV_TB_CARGUE_MASIVO_DET WHERE ID_CARGUE = p_id_cargue;
    EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM MSV_TB_CARGUE_MASIVO_DET. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
    END;

    BEGIN
    SELECT COUNT(crespue) INTO v_contar  FROM pregunpolseg where cpregun = 4086 and sseguro = v_seguro;
    EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM pregunpolseg. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
    END;

    IF (v_contar != 0) THEN 
      SELECT crespue INTO v_con_aseg_pre  FROM pregunpolseg where cpregun = 4086 and sseguro = v_seguro;
    END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '9366 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
    FOR x IN (SELECT ID_CARGUE,NRO_LINEA,TEXTO FROM MSV_TB_CARGUE_MASIVO_DET WHERE ID_CARGUE = p_id_cargue ORDER BY NRO_LINEA)
    LOOP
    t_tmp_array := pac_msv_utilidades.fu_split(x.texto, pac_msv_constantes.c_caracter_coma);
    -- INICIO - 24/03/2021 - Company - Ar 37175
    IF t_tmp_array.EXISTS(20) = FALSE THEN
      v_traecel := false;      
    END IF;
    -- FIN - 24/03/2021 - Company - Ar 37175
--INICIO 14.0
      /*FOR y IN (SELECT ID_CARGUE,NRO_LINEA,TEXTO FROM MSV_TB_CARGUE_MASIVO_DET WHERE ID_CARGUE = p_id_cargue ORDER BY NRO_LINEA)
      LOOP
        t_tmp_array_val := pac_msv_utilidades.fu_split(y.texto, pac_msv_constantes.c_caracter_coma);
        IF (t_tmp_array_val(4) = t_tmp_array(4) AND t_tmp_array_val(5) = t_tmp_array(5)) THEN 
          v_conta := v_conta + 1;
        END IF;
      END LOOP;*/
      BEGIN
      SELECT COUNT(1)
      INTO v_conta
      FROM MSV_TB_CARGUE_MASIVO_DET
      WHERE ID_CARGUE = p_id_cargue 
      AND UPPER(SUBSTR(TEXTO,(INSTR(TEXTO, ';', 1, 4) + 1), ((INSTR(TEXTO, ';', 1, 5)) - (INSTR(TEXTO, ';', 1, 4) + 1)))) = t_tmp_array(4)
      AND SUBSTR(TEXTO,(INSTR(TEXTO, ';', 1, 5) + 1), ((INSTR(TEXTO, ';', 1, 6)) - (INSTR(TEXTO, ';', 1, 5) + 1))) = t_tmp_array(5);
      EXCEPTION
        WHEN OTHERS THEN
          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM SEGUROS. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
      END;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '9394 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
      --FOR z IN (SELECT ID_CARGUE,NRO_LINEA,TEXTO FROM MSV_TB_CARGUE_MASIVO_DET WHERE ID_CARGUE = p_id_cargue ORDER BY NRO_LINEA)
      --LOOP
        --t_tmp_array_val := pac_msv_utilidades.fu_split(z.texto, pac_msv_constantes.c_caracter_coma);
        IF(t_tmp_array(4) != 'NA') THEN

          IF UPPER(t_tmp_array(13)) = 'IN 'THEN

            -- INICIO - Company - 02/09/2020 - AR 36669 - Inconsistencias al validar cargue masivo
            IF t_tmp_array(4) = 'TI' THEN      v_tipo_doc := 34;   -- v_tipo_doc2 := 34;
              ELSIF t_tmp_array(4) = 'CC' THEN   v_tipo_doc := 36; -- v_tipo_doc2 := 36;
              ELSIF t_tmp_array(4) = 'NIT' THEN  v_tipo_doc := 37; -- v_tipo_doc2 := 37;
              ELSIF t_tmp_array(4) = 'RC' THEN   v_tipo_doc := 35; -- v_tipo_doc2 := 35;
              ELSIF t_tmp_array(4) = 'CE' THEN   v_tipo_doc := 33; -- v_tipo_doc2 := 33;
              ELSIF t_tmp_array(4) = 'PA' THEN   v_tipo_doc := 40; -- v_tipo_doc2 := 40;
              ELSIF t_tmp_array(4) = 'DE' THEN   v_tipo_doc := 42; -- v_tipo_doc2 := 42;
              ELSIF t_tmp_array(4) = 'CD' THEN   v_tipo_doc := 44; -- v_tipo_doc2 := 44;
              ELSIF t_tmp_array(4) = 'NA' THEN  v_tipo_doc := 0;   -- v_tipo_doc2 := 0;
              -- INICIO - Company - 07/04/2021 - Ar 39653 - Validacion tipo documento numero unico identificacion
              ELSIF t_tmp_array(4) = 'NUIP' THEN  v_tipo_doc := 38;   -- v_tipo_doc2 := 0;
              -- FIN - Company -  07/04/2021 - Ar 39653 - Validacion tipo documento numero unico identificacion
              -- 39653
              -- FIN - Company - 02/09/2020 - AR 36669 - Inconsistencias al validar cargue masivo
              -- INICIO - Company - 04/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
              -- INICIO - Company - 02/09/2020 - AR 36669 - Inconsistencias al validar cargue masivo
              --Ini Company(LARO) 28112020 Factura Electronica
              --ELSIF t_tmp_array(4) = 'N A' THEN  v_tipo_doc := 0; -- v_tipo_doc2 := 0;
              ELSIF t_tmp_array(4) = 'N A' THEN  
              BEGIN
                 SELECT CRESPUE
                   INTO v_pregun535
                   FROM PREGUNPOLSEG 
                  WHERE SSEGURO = (SELECT SSEGURO FROM SEGUROS WHERE NPOLIZA = v_poliza AND NCERTIF = 0)
                    AND CPREGUN = 535 
                    AND NMOVIMI = (SELECT MAX(NMOVIMI)
                                     FROM PREGUNPOLSEG 
                                    WHERE SSEGURO = (SELECT SSEGURO FROM SEGUROS WHERE NPOLIZA = v_poliza AND NCERTIF = 0)
                                      AND CPREGUN = 535);
              -- INICIO CP 205
                EXCEPTION
                  WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS',1,' ERROR SELECT PREGUNPOLSEG ' , SQLERRM);
              END;
                 --0    =   Asegurado
                 --100  =   Tomador   
                 IF v_pregun535 = 0 THEN
                    vr_observaciones := vr_observaciones || PAC_MSV_CONSTANTES.c_tipo_identificacion || ',';
                    v_resultado := v_resultado + 1;
                 ELSE
                    v_tipo_doc := 0; 
                 END IF;
              -- INICIO CP 205  
              --Fin Company(LARO) 28112020 Factura Electronica
              -- FIN - Company - 02/09/2020 - AR 36669 - Inconsistencias al validar cargue masivo
              ELSE 
                vr_observaciones := vr_observaciones ||'  El campo tipo de documento '|| PAC_MSV_CONSTANTES.c_tipo_identificacion || ',';
                v_resultado := v_resultado + 1;
              -- FIN - Company - 04/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
              END IF;
              BEGIN
                /*SELECT COUNT(*)
                 INTO nexiste
                 FROM PER_PERSONAS P, ASEGURADOS A,SEGUROS S
                 WHERE S.SSEGURO IN(SELECT SSEGURO FROM SEGUROS WHERE SSEGURO = S.SSEGURO  AND NCERTIF <>0 AND NPOLIZA  = v_poliza)
                  AND S.SSEGURO = A.SSEGURO
                  AND A.SPERSON = P.SPERSON
                  AND P.NNUMIDE = to_char(t_tmp_array(5))
                  AND P.CTIPIDE = v_tipo_doc2;*/
                  SELECT COUNT(1)
                  INTO nexiste
                  FROM PER_PERSONAS P
                  JOIN ASEGURADOS A ON A.SPERSON = P.SPERSON
                  JOIN SEGUROS S ON S.SSEGURO = A.SSEGURO
                  WHERE S.SSEGURO IN(SELECT SSEGURO FROM SEGUROS WHERE SSEGURO = S.SSEGURO  AND NCERTIF <>0 AND NPOLIZA  = v_poliza)
                  AND P.NNUMIDE = to_char(t_tmp_array(5))
                  -- INICIO - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
                  --AND P.CTIPIDE = v_tipo_doc2;
                  AND P.CTIPIDE = v_tipo_doc;
                  -- FIN - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
              EXCEPTION 
              WHEN NO_DATA_FOUND THEN 
                nexiste := 0;
              WHEN TOO_MANY_ROWS THEN
                nexiste := 1;
              WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM PER_PERSONAS. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
              END;
              if nexiste >1 then
              nconta2:= nconta2 + 1;
              end if;
          END IF;
        END IF;
      --END LOOP;
--FIN 14.0
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '9488 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
      IF(v_con_aseg_pre != 0) THEN
        IF(v_con_aseg_pre <  v_con_aseg) THEN 
          vr_observaciones := vr_observaciones ||' La cantidad de asegurados que tiene el documento excede a los permitidos por la poliza'||  ',';
          v_resultado := v_resultado + 1;
        END IF;
      END IF;

      IF (v_conta > 1 OR nconta2 > 1) THEN
        vr_observaciones := vr_observaciones ||'El asegurado tiene '|| PAC_MSV_CONSTANTES.c_reg_duplicaso || ' o existe en poliza,';
        v_resultado := v_resultado + 1;
      END IF;

      IF(t_tmp_array(13) IS NOT NULL OR t_tmp_array(13) != '')  THEN 
        IF(UPPER(t_tmp_array(13)) != 'IN' AND UPPER(t_tmp_array(13))  != 'EX')  THEN 
          vr_observaciones := vr_observaciones ||' El campo tipo de novedad tiene que ser una INCLUCION O UNA EXCLUCION '|| ',';
          v_resultado := v_resultado + 1;
        END IF;
      END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '9507 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
    IF(t_tmp_array(13) IS NOT NULL OR t_tmp_array(13) != '')  THEN 
      IF (f_buscar_no_imprimible(t_tmp_array(13)) >= 1) THEN
          vr_observaciones := vr_observaciones ||' El campo tipo de novedad '|| PAC_MSV_CONSTANTES.c_caract_especiales || ',';
          v_resultado := v_resultado + 1;
        ELSE
      --TIPO CARGUE DE INCLUCIONES. 
        IF (t_tmp_array(13) = 'IN') THEN
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '9515 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
          -- INICIO Incidencias cargue masivo 18/02/2021
          -- Valida caracteres especiales en nombres y apellidos
          IF(t_tmp_array(0) IS NOT NULL OR t_tmp_array(0) != '')  THEN 
            IF (f_buscar_no_imprimible(t_tmp_array(0)) >= 1) THEN
              vr_observaciones := vr_observaciones ||' El campo primer nombre '|| PAC_MSV_CONSTANTES.c_caract_especiales || ',';
              v_resultado := v_resultado + 1;
            END IF;
          END IF;

          IF(t_tmp_array(1) IS NOT NULL OR t_tmp_array(1) != '')  THEN 
            IF (f_buscar_no_imprimible(t_tmp_array(1)) >= 1) THEN
              vr_observaciones := vr_observaciones ||' El campo segundo nombre '|| PAC_MSV_CONSTANTES.c_caract_especiales || ',';
              v_resultado := v_resultado + 1;
            END IF;
          END IF;

          IF(t_tmp_array(2) IS NOT NULL OR t_tmp_array(2) != '')  THEN 
            IF (f_buscar_no_imprimible(t_tmp_array(2)) >= 1) THEN
              vr_observaciones := vr_observaciones ||' El campo primer apellido '|| PAC_MSV_CONSTANTES.c_caract_especiales || ',';
              v_resultado := v_resultado + 1;
            END IF;
          END IF;

          IF(t_tmp_array(3) IS NOT NULL OR t_tmp_array(3) != '')  THEN 
            IF (f_buscar_no_imprimible(t_tmp_array(3)) >= 1) THEN
              vr_observaciones := vr_observaciones ||' El campo segundo apellido '|| PAC_MSV_CONSTANTES.c_caract_especiales || ',';
              v_resultado := v_resultado + 1;
            END IF;
          END IF;
          -- FIN Incidencias cargue masivo 18/02/2021

          IF (t_tmp_array(0) = '' OR t_tmp_array(0) IS NULL) THEN
            vr_observaciones := vr_observaciones ||'  El campo primer nombre es '|| PAC_MSV_CONSTANTES.c_camp_obligatorio || ',';
            v_resultado := v_resultado + 1;
          END IF;
          IF (t_tmp_array(2) = '' OR t_tmp_array(2) IS NULL) THEN
            vr_observaciones := vr_observaciones ||'  El campo primer apellido es '|| PAC_MSV_CONSTANTES.c_camp_obligatorio || ',';
            v_resultado := v_resultado + 1;
          END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '9555 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
          IF (t_tmp_array(4) != '' OR t_tmp_array(4) IS NOT NULL) THEN
            IF t_tmp_array(4) = 'TI' THEN      v_tipo_doc := 34;
            ELSIF t_tmp_array(4) = 'CC' THEN   v_tipo_doc := 36;
            ELSIF t_tmp_array(4) = 'NIT' THEN  v_tipo_doc := 37;
            ELSIF t_tmp_array(4) = 'RC' THEN   v_tipo_doc := 35;
            ELSIF t_tmp_array(4) = 'CE' THEN   v_tipo_doc := 33;
            ELSIF t_tmp_array(4) = 'PA' THEN   v_tipo_doc := 40;
            ELSIF t_tmp_array(4) = 'DE' THEN   v_tipo_doc := 42;
            ELSIF t_tmp_array(4) = 'CD' THEN   v_tipo_doc := 44;
            ELSIF t_tmp_array(4) = 'NA' THEN  v_tipo_doc := 0;
            -- INICIO - Company - 07/04/2021 - Ar 39653 - Validacion tipo documento numero unico identificacion
            ELSIF t_tmp_array(4) = 'NUIP' THEN  v_tipo_doc := 38;   -- v_tipo_doc2 := 0;
            -- FIN - Company -  07/04/2021 - Ar 39653 - Validacion tipo documento numero unico identificacion
            -- INICIO - Company - 04/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
--INICIO 14.0
            -- INICIO - Company - 31/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
            --ELSIF t_tmp_array(4) = 'N A' THEN  v_tipo_doc2 := 0;  
            --Ini Company(LARO) 28112020 Factura Electronica
              --ELSIF t_tmp_array(4) = 'N A' THEN  v_tipo_doc := 0;
              ELSIF t_tmp_array(4) = 'N A' THEN  
              BEGIN
                 SELECT CRESPUE
                   INTO v_pregun535
                   FROM PREGUNPOLSEG 
                  WHERE SSEGURO = (SELECT SSEGURO FROM SEGUROS WHERE NPOLIZA = v_poliza AND NCERTIF = 0)
                    AND CPREGUN = 535 
                    AND NMOVIMI = (SELECT MAX(NMOVIMI)
                                     FROM PREGUNPOLSEG 
                                    WHERE SSEGURO = (SELECT SSEGURO FROM SEGUROS WHERE NPOLIZA = v_poliza AND NCERTIF = 0)
                                      AND CPREGUN = 535);
              EXCEPTION
                WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM PREGUNPOLSEG. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
              END;
              --0    =   Asegurado
              --100  =   Tomador   
              IF v_pregun535 = 0 THEN
                vr_observaciones := vr_observaciones || PAC_MSV_CONSTANTES.c_tipo_identificacion || ',';
                v_resultado := v_resultado + 1;
              ELSE
                v_tipo_doc := 0; 
              END IF;

              --Fin Company(LARO) 28112020 Factura Electronica
            -- FIN - Company - 31/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
--FIN 14.0
            ELSE 
              vr_observaciones := vr_observaciones ||'  El campo tipo de documento '|| PAC_MSV_CONSTANTES.c_tipo_identificacion || ',';
              v_resultado := v_resultado + 1;
            -- FIN - Company - 04/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
            END IF;

            IF (f_buscar_no_imprimible(t_tmp_array(4)) >= 1) THEN
              vr_observaciones := vr_observaciones ||'  El campo tipo de documento '|| PAC_MSV_CONSTANTES.c_caract_especiales || ',';
              v_resultado := v_resultado + 1;

            END IF;
          ELSE
            vr_observaciones := vr_observaciones ||'  El campo tipo de documento es '|| PAC_MSV_CONSTANTES.c_camp_obligatorio || ',';
            v_resultado := v_resultado + 1;
          END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '9617 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
          v_con_aseg := 0;
--INICIO 14.0
          IF(t_tmp_array(4) != 'NA') THEN 
--FIN 14.0
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '9622 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
          IF(v_tipo_doc = 40) THEN
            IF (t_tmp_array(5) != '' OR t_tmp_array(5) IS NOT NULL) THEN
            IF (f_buscar_imprimible_letra_numero(t_tmp_array(5)) >= 1) THEN
              vr_observaciones := vr_observaciones ||'  El campo numero documento '|| PAC_MSV_CONSTANTES.c_comp_formato || ',';
              v_resultado := v_resultado + 1;
              ELSE
                -- INICIO - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
                BEGIN
                  SELECT COUNT( 1 )
                    INTO v_con_aseg
                    FROM asegurados a
                    JOIN seguros s on s.sseguro = a.sseguro
                    JOIN per_personas pp on pp.sperson = a.sperson
                   WHERE s.sseguro in (SELECT SSEGURO FROM SEGUROS WHERE npoliza = v_poliza and ncertif <>0)
                     AND pp.ctipide  = v_tipo_doc
                     AND pp.nnumide = t_tmp_array(5);
                EXCEPTION
                  WHEN OTHERS THEN
                    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS',1,'EXCEPCION SELECT ASEGURADOS: ' || Sqlerrm, Sqlerrm);
                END;
                /*
                FOR z IN (SELECT SSEGURO FROM SEGUROS WHERE NPOLIZA = v_poliza)
                LOOP
                  SELECT NNUMIDE INTO v_documen_ex  FROM PER_PERSONAS pe WHERE pe.sperson = (SELECT SPERSON FROM ASEGURADOS WHERE SSEGURO = z.sseguro);
                  SELECT CTIPIDE INTO v_tipo_doc_ex FROM PER_PERSONAS pr WHERE pr.sperson = (SELECT SPERSON FROM ASEGURADOS WHERE SSEGURO = z.sseguro);
                  IF (v_documen_ex = t_tmp_array(5) AND v_tipo_doc_ex = v_tipo_doc) THEN
                      v_con_aseg := 1;
                  END IF;
                END LOOP;
                */
                --IF (v_con_aseg = 1) THEN 
                IF NVL(v_con_aseg,0) > 0 THEN
                -- FIN - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
                   vr_observaciones := vr_observaciones ||' '|| PAC_MSV_CONSTANTES.c_aseg_registrado || ',';
                   v_resultado := v_resultado + 1;
                END IF;
            END IF;
          ELSE
            vr_observaciones := vr_observaciones ||'  El campo numero documento es '|| PAC_MSV_CONSTANTES.c_camp_obligatorio || ',';
            v_resultado := v_resultado + 1;
          END IF;
          --OTROS TIPOS DE DOCUMENTOS.
          ELSE
          v_con_aseg := 0;

          IF (t_tmp_array(5) != '' OR t_tmp_array(5) IS NOT NULL) THEN
            IF (f_buscar_no_imprimible_letra(t_tmp_array(5)) >= 1) THEN
              vr_observaciones := vr_observaciones ||'  El campo numero documento '|| PAC_MSV_CONSTANTES.c_comp_formato || ',';
              v_resultado := v_resultado + 1;
              ELSE
                -- INICIO - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
                BEGIN
                  SELECT COUNT( 1 )
                    INTO v_con_aseg
                    FROM asegurados a
                    JOIN seguros s on s.sseguro = a.sseguro
                    JOIN per_personas pp on pp.sperson = a.sperson
                   WHERE s.sseguro in (SELECT SSEGURO FROM SEGUROS WHERE npoliza = v_poliza and ncertif <>0)
                     AND pp.ctipide  = v_tipo_doc
                     AND pp.nnumide = t_tmp_array(5);
                EXCEPTION
                  WHEN OTHERS THEN
                    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS',1,'EXCEPCION SELECT ASEGURADOS: ' || Sqlerrm, Sqlerrm);
                END;
                /*
                FOR z IN (SELECT SSEGURO FROM SEGUROS WHERE NPOLIZA = v_poliza)
                LOOP
                  SELECT NNUMIDE INTO v_documen_ex  FROM PER_PERSONAS pe WHERE pe.sperson = (SELECT SPERSON FROM ASEGURADOS WHERE SSEGURO = z.sseguro);
                  SELECT CTIPIDE INTO v_tipo_doc_ex FROM PER_PERSONAS pr WHERE pr.sperson = (SELECT SPERSON FROM ASEGURADOS WHERE SSEGURO = z.sseguro);
                  IF (v_documen_ex = t_tmp_array(5) AND v_tipo_doc_ex = v_tipo_doc) THEN
                      v_con_aseg := 1;
                  END IF;
                END LOOP;
                */
                --IF (v_con_aseg = 1) THEN 
                IF NVL(v_con_aseg,0) > 0 THEN 
                -- FIN - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
                   vr_observaciones := vr_observaciones ||' '|| PAC_MSV_CONSTANTES.c_aseg_registrado || ',';
                   v_resultado := v_resultado + 1;
                END IF;
            END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '9704 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
          ELSE
            -- INICIO - Company - 04/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
            -- Si el tipo de documento es diferente a N A o NA entonces debe ser obligatorio el numero de documento
            IF v_tipo_doc <> 0 THEN
            -- FIN - Company - 04/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
            vr_observaciones := vr_observaciones ||'  El campo numero documento es '|| PAC_MSV_CONSTANTES.c_camp_obligatorio || ',';
            v_resultado := v_resultado + 1;
            -- INICIO - Company - 04/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
            END IF;
            -- FIN - Company - 04/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '9715 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
          END IF;
          END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '9718 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
            ELSE
            IF (t_tmp_array(5) != '' OR t_tmp_array(5) IS NOT NULL) THEN
              IF (f_buscar_imprimible_letra_numero(t_tmp_array(5)) >= 1) THEN
                vr_observaciones := vr_observaciones ||'  El campo numero documento '|| PAC_MSV_CONSTANTES.c_comp_formato || ',';
                v_resultado := v_resultado + 1;
              END IF;
            END IF;
          END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '9727 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
          IF (t_tmp_array(6) != '' OR t_tmp_array(6) IS NOT NULL) THEN
            IF (f_buscar_no_imprimible(t_tmp_array(6)) >= 1) THEN
                vr_observaciones := vr_observaciones ||'  El campo genero '|| PAC_MSV_CONSTANTES.c_caract_especiales || ',';
                v_resultado := v_resultado + 1;
            END IF;
            IF(t_tmp_array(6) != 'M' AND t_tmp_array(6) != 'F') THEN 
                vr_observaciones := vr_observaciones ||'  El campo genero debe de ser F(Femenino) o M(Masculino),';
                v_resultado := v_resultado + 1;
              END IF;
          END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '9738 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
          -- INICIO Incidencias cargue masivo 18/02/2021
          -- Campo genero debe ser obligatorio
          IF (t_tmp_array(6) = '' OR t_tmp_array(6) IS NULL) THEN
                vr_observaciones := vr_observaciones ||'  El campo genero '|| PAC_MSV_CONSTANTES.c_camp_obligatorio || ',';
                v_resultado := v_resultado + 1;
          END IF;
          -- FIN Incidencias cargue masivo 18/02/2021

          IF (t_tmp_array(7) != '' OR t_tmp_array(7) IS NOT NULL) THEN
            v_date := NULL;

              begin
                select to_date(t_tmp_array(7),'DD/MM/YYYY') into v_date from dual;
                v_cumple :=0;
                exception when others then 
                v_cumple := 1;
              end;

            IF (v_cumple != 0) THEN

              vr_observaciones := vr_observaciones ||'  El campo fecha de nacimiento '|| PAC_MSV_CONSTANTES.c_comp_formato || ',';
              v_resultado := v_resultado + 1;
            END IF;
          ELSE

            vr_observaciones := vr_observaciones ||'  El campo fecha de nacimiento es '|| PAC_MSV_CONSTANTES.c_camp_obligatorio || ',';
            v_resultado := v_resultado + 1;
          END IF;

         -- v_edad := sysdate - TO_DATE(t_tmp_array(7)) ;
          BEGIN  
            v_edad := NVL(ROUND((TO_NUMBER(TRUNC(sysdate) - TO_DATE(t_tmp_array(7),'dd/mm/yyyy')) / 365),1),0);
          EXCEPTION WHEN OTHERS THEN
            v_edad := 0;
          END;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '9774 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
          IF (t_tmp_array(9) != '' OR t_tmp_array(9) IS NOT NULL) THEN

            BEGIN
              SELECT COUNT(*)
              INTO val_numero
              FROM dual 
              WHERE REGEXP_LIKE (t_tmp_array(9), '^[0-9]+$');
            EXCEPTION
              WHEN OTHERS THEN
                p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS',1,'EXCEPCION SELECT VALIDA PLAN ', Sqlerrm);
            END;

            IF val_numero = 0 OR (f_buscar_no_imprimible_letra(t_tmp_array(9)) >= 1) THEN
              validaplanok := false;
              vr_observaciones := vr_observaciones ||'  El campo plan '|| PAC_MSV_CONSTANTES.c_comp_formato;
              v_resultado := v_resultado + 1;
            END IF;

          IF val_numero > 0 then
          FOR y IN (SELECT CGARANT FROM GARANSEG WHERE SSEGURO = v_seguro AND NMOVIMI = (SELECT MAX(NMOVIMI) FROM GARANSEG WHERE SSEGURO = v_seguro) and nriesgo = t_tmp_array(9))
          LOOP
            BEGIN 
              SELECT CRESPUE INTO v_edadmin FROM PREGUNGARANSEG WHERE nriesgo = t_tmp_array(9) and CPREGUN = 4798 AND SSEGURO = v_seguro AND CGARANT = y.CGARANT AND NMOVIMI = (SELECT MAX(NMOVIMI) FROM PREGUNGARANSEG WHERE CPREGUN = 4798 AND SSEGURO = v_seguro AND CGARANT = y.CGARANT and nriesgo = t_tmp_array(9));
            EXCEPTION 
              WHEN OTHERS THEN v_edadmin := 0; 
            END;

            BEGIN 
              SELECT CRESPUE INTO v_edadmax FROM PREGUNGARANSEG WHERE nriesgo = t_tmp_array(9) and CPREGUN = 4799 AND SSEGURO = v_seguro AND CGARANT = y.CGARANT AND NMOVIMI = (SELECT MAX(NMOVIMI) FROM PREGUNGARANSEG WHERE CPREGUN = 4799 AND SSEGURO = v_seguro AND CGARANT = y.CGARANT and nriesgo = t_tmp_array(9));
            EXCEPTION 
              WHEN OTHERS THEN v_edadmin := 100; 
            END;

              IF (v_edad < v_edadmin OR v_edad > v_edadmax) THEN 
               vr_observaciones := vr_observaciones ||'  Edad del asegurado fuera de los limites , ';
               v_resultado := v_resultado + 1; 
               EXIT;
              END IF;
          END LOOP;
          END IF;


          IF (t_tmp_array(8) != '' OR t_tmp_array(8) IS NOT NULL) THEN
            v_date := NULL;

              begin
                select to_date(t_tmp_array(8),'DD/MM/YYYY') into v_date from dual;
                v_cumple :=0;
                exception when others then 
                v_cumple := 1;
              end;
            IF (v_cumple != 0) THEN

              vr_observaciones := vr_observaciones ||'  El campo fecha efecto novedad '|| PAC_MSV_CONSTANTES.c_comp_formato || ',';
              v_resultado := v_resultado + 1;
              ELSE 

                IF(v_date NOT BETWEEN v_fec_ini AND v_fec_fin) THEN 
                  vr_observaciones := vr_observaciones ||' '|| PAC_MSV_CONSTANTES.c_fec_ingre_vigencia || ',';
                  v_resultado := v_resultado + 1;
                END IF;
            END IF;
          ELSE

            vr_observaciones := vr_observaciones ||'  El campo fecha efecto novedad es '|| PAC_MSV_CONSTANTES.c_camp_obligatorio || ',';
            v_resultado := v_resultado + 1;
          END IF;
          
            /*IF (f_buscar_no_imprimible_letra(t_tmp_array(9)) >= 1) THEN
              vr_observaciones := vr_observaciones ||'  El campo plan '|| PAC_MSV_CONSTANTES.c_comp_formato || ',';
              v_resultado := v_resultado + 1;
              ELSE*/
            IF validaplanok THEN
              BEGIN
              SELECT SSEGURO INTO v_seguro FROM SEGUROS WHERE NPOLIZA = v_poliza AND NCERTIF = 0;
              EXCEPTION
                WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM SEGUROS. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
              END;

              BEGIN    
              SELECT COUNT(*) INTO v_con_plan FROM RIESGOS WHERE SSEGURO = v_seguro AND NRIESGO = t_tmp_array(9);
              EXCEPTION
                WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM RIESGOS. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
              END;

              IF (v_con_plan < 1) THEN
              -- INICIO - 20/01/2021 Ar 38616
              --vr_observaciones := vr_observaciones || PAC_MSV_CONSTANTES.c_plan_noexiste|| v_con_plan || ',';
              vr_observaciones := vr_observaciones || PAC_MSV_CONSTANTES.c_plan_noexiste || ',';
              -- FIN - 20/01/2021 Ar 38616
              v_resultado := v_resultado + 1;
              END IF;
            END IF;

            ELSE
              vr_observaciones := vr_observaciones ||'  El campo plan es '|| PAC_MSV_CONSTANTES.c_camp_obligatorio || ',';
              v_resultado := v_resultado + 1;
            END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '9875 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
            IF (t_tmp_array(10) != '' OR t_tmp_array(10) IS NOT NULL) THEN
              IF (f_buscar_imprimible_letra_numero(t_tmp_array(10)) >= 1) THEN
                vr_observaciones := vr_observaciones ||'  El campo codigo '|| PAC_MSV_CONSTANTES.c_caract_especiales || ',';
                v_resultado := v_resultado + 1;
              ELSE 
                vr_estado := 'OK';
              END IF;
          END IF;

          IF (t_tmp_array(11) != '' OR t_tmp_array(11) IS NOT NULL) THEN
            IF (f_buscar_imprimible_letra_numero(t_tmp_array(11)) >= 1) THEN
              vr_observaciones := vr_observaciones ||'  El campo curso o sede '|| PAC_MSV_CONSTANTES.c_caract_especiales || ',';
              v_resultado := v_resultado + 1;

            END IF;
          END IF;

          IF (t_tmp_array(12) != '' OR t_tmp_array(12) IS NOT NULL) THEN
            IF (f_buscar_imprimible_correo(t_tmp_array(12)) >= 1) THEN
              vr_observaciones := vr_observaciones ||'  El campo Correo Electronico del Asegurado '|| PAC_MSV_CONSTANTES.c_caract_especiales;
              v_resultado := v_resultado + 1;

            END IF;
          END IF;

          -- INICIO Incidencias cargue masivo 18/02/2021
          IF (t_tmp_array(14) != '' OR t_tmp_array(14) IS NOT NULL) THEN
              vr_observaciones := vr_observaciones ||'  El campo Motivo de Anulacion del Asegurado no debe diligenciarse cuando es inclusion';
              v_resultado := v_resultado + 1;
          END IF;
          -- FIN Incidencias cargue masivo 18/02/2021

          -- INICIO - 24/03/2021 - Company - Ar 37175
          /*
          -- Ajuste incidencias cague masivo
          BEGIN
            SELECT CRESPUE
              INTO v_pregun535
              FROM PREGUNPOLSEG 
             WHERE SSEGURO = (SELECT SSEGURO FROM SEGUROS WHERE NPOLIZA = v_poliza AND NCERTIF = 0)
               AND CPREGUN = 535 
               AND NMOVIMI = (SELECT MAX(NMOVIMI)
                                FROM PREGUNPOLSEG 
                               WHERE SSEGURO = (SELECT SSEGURO FROM SEGUROS WHERE NPOLIZA = v_poliza AND NCERTIF = 0)
                                 AND CPREGUN = 535);
              -- INICIO CP 205
          EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS',1,' ERROR SELECT PREGUNPOLSEG ' , SQLERRM);
          END;
          -- INICIO - 18/02/2021 - Company - Incidencias Cargue Masivo
          -- Valida si la pregunta 535 "Recibo por" es por asegurado (0) o tomador (100) y si es por asegurado (0) entonces aplica obligatorio
          -- datos de facturacion electronica (correo, direccion, depto, ciudad, telefono fijo, telefono movil, etc)
          IF v_pregun535 = 0 THEN
            IF (t_tmp_array(12) = '' OR t_tmp_array(12) IS NULL) THEN
                vr_observaciones := vr_observaciones ||'  El campo Correo electronico del Asegurado '|| PAC_MSV_CONSTANTES.c_camp_obligatorio;
                v_resultado := v_resultado + 1;
            END IF;


            IF (t_tmp_array(16) = '' OR t_tmp_array(16) IS NULL) THEN
                vr_observaciones := vr_observaciones ||'  El campo Direccion del Asegurado '|| PAC_MSV_CONSTANTES.c_camp_obligatorio;
                v_resultado := v_resultado + 1;
            END IF;

            IF (t_tmp_array(17) = '' OR t_tmp_array(17) IS NULL) THEN
                vr_observaciones := vr_observaciones ||'El campo Departamento del Asegurado '|| PAC_MSV_CONSTANTES.c_camp_obligatorio;
                v_resultado := v_resultado + 1;
            END IF;

            IF (t_tmp_array(18) = '' OR t_tmp_array(18) IS NULL) THEN
                vr_observaciones := vr_observaciones ||'  El campo Ciudad del Asegurado '|| PAC_MSV_CONSTANTES.c_camp_obligatorio;
                v_resultado := v_resultado + 1;
            END IF;

            IF (t_tmp_array(19) = '' OR t_tmp_array(19) IS NULL) THEN
                vr_observaciones := vr_observaciones ||'  El campo Telefono Fijo del Asegurado '|| PAC_MSV_CONSTANTES.c_camp_obligatorio;
                v_resultado := v_resultado + 1;
            END IF;

            IF (t_tmp_array(20) = '' OR t_tmp_array(20) IS NULL) THEN
                vr_observaciones := vr_observaciones ||'  El campo Telefono Movil del Asegurado '|| PAC_MSV_CONSTANTES.c_camp_obligatorio;
                v_resultado := v_resultado + 1;
            END IF;

          END IF;
          -- FIN - 18/02/2021 - Company - Incidencias Cargue Masivo
          */
          -- INICIO - 16/04/2021 - Company - Ar 39694 - Inconsistencia validacion datos Direccion, ciudad y departamento
          -- t_tmp_array(16) Direccion - t_tmp_array(17) Departamento - t_tmp_array(18) Ciudad
          IF (t_tmp_array(16) IS NOT NULL AND ( t_tmp_array(17) IS NULL OR t_tmp_array(18) IS NULL)) OR (t_tmp_array(17) IS NOT NULL AND ( t_tmp_array(16) IS NULL OR t_tmp_array(18) IS NULL)) OR (t_tmp_array(18) IS NOT NULL AND ( t_tmp_array(16) IS NULL OR t_tmp_array(17) IS NULL)) THEN 
          vr_observaciones := vr_observaciones ||' Campos de Domicilio Incompletos, ingresar Departamento, Ciudad y Dirección en caso de ingresar uno de ellos ';
            v_resultado := v_resultado + 1;
          END IF;
          -- FIN - 16/04/2021 - Company - Ar 39694 - Inconsistencia validacion datos Direccion, ciudad y departamento
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '9971 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
          -- INICIO - 06/04/2021 - Company - Control de cambios cargue masivo validacion direccion, departamento y ciudad
          /*
          IF t_tmp_array(16) IS NOT NULL AND (t_tmp_array(17) IS NULL OR t_tmp_array(18) IS NULL) THEN

            vr_observaciones := vr_observaciones ||' Debe informarse el departamento y/o ciudad cuando se informa la Direccion '|| PAC_MSV_CONSTANTES.c_comp_formato;
            v_resultado := v_resultado + 1;
          END IF;

          IF t_tmp_array(17) IS NOT NULL AND (t_tmp_array(16) IS NULL OR t_tmp_array(18) IS NULL) THEN

            vr_observaciones := vr_observaciones ||' Debe informarse la direccion y/o ciudad cuando se informa el departamento '|| PAC_MSV_CONSTANTES.c_comp_formato;
            v_resultado := v_resultado + 1;
          END IF;

          IF t_tmp_array(18) IS NOT NULL AND (t_tmp_array(16) IS NULL OR t_tmp_array(17) IS NULL) THEN

            vr_observaciones := vr_observaciones ||' Debe informarse la direccion y/o departamento cuando se informa la ciudad '|| PAC_MSV_CONSTANTES.c_comp_formato;
            v_resultado := v_resultado + 1;
          END IF;
          */
          -- FIN - 06/04/2021 - Company - Control de cambios cargue masivo validacion direccion, departamento y ciudad

          -- FIN - 24/03/2021 - Company - Ar 37175
          -- INICIO - 11/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
          /*
          IF (t_tmp_array(17) = '' OR t_tmp_array(17) IS NULL) THEN
              vr_observaciones := vr_observaciones ||'El campo Departamento del Asegurado '|| 'no esta diligenciado';
              v_resultado := v_resultado + 1;
          END IF;

          IF (t_tmp_array(18) = '' OR t_tmp_array(18) IS NULL) THEN
              vr_observaciones := vr_observaciones ||'  El campo Ciudad del Asegurado '|| 'no esta diligenciado';
              v_resultado := v_resultado + 1;
          END IF;
           */
          -- Se valida si se ingreso el campo departamento con codigo numerico
          IF (t_tmp_array(17) != '' OR t_tmp_array(17) IS NOT NULL) THEN
            BEGIN
              SELECT COUNT(*)
              INTO val_numero
              FROM dual 
              WHERE REGEXP_LIKE (t_tmp_array(17), '^[0-9]+$');
            EXCEPTION
              WHEN OTHERS THEN
                p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS',1,'EXCEPCION SELECT VALIDA DEPTO ', Sqlerrm);
            END;

            IF val_numero = 0 THEN

              vr_observaciones := vr_observaciones ||'El campo Departamento del Asegurado '|| PAC_MSV_CONSTANTES.c_comp_formato;
              v_resultado := v_resultado + 1;
            ELSE

              BEGIN
                SELECT 1
                INTO v_estadepto
                FROM provincias
                WHERE cprovin = t_tmp_array(17)
                AND cpais = 170;
              EXCEPTION 
                WHEN OTHERS THEN
                  v_estadepto := 0;
                  p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS',1,'EXCEPCION SELECT VALIDA DEPTO ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , Sqlerrm);
              END;

              IF NVL(v_estadepto,0) <> 1 THEN
                vr_observaciones := vr_observaciones ||'El campo Departamento del Asegurado no existe.';
                v_resultado := v_resultado + 1;
              END IF;
            END IF;

          END IF;

          -- Se valida si se ingreso el campo ciudad con codigo numerico
          IF (t_tmp_array(18) != '' OR t_tmp_array(18) IS NOT NULL) THEN
            BEGIN
              SELECT COUNT(*)
              INTO val_numero
              FROM dual 
              WHERE REGEXP_LIKE (t_tmp_array(18), '^[0-9]+$');
            EXCEPTION
              WHEN OTHERS THEN
                p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS',1,'EXCEPCION SELECT VALIDA DEPTO ', Sqlerrm);
            END;

            IF val_numero = 0 THEN

              vr_observaciones := vr_observaciones ||'  El campo Ciudad del Asegurado '|| PAC_MSV_CONSTANTES.c_comp_formato;
              v_resultado := v_resultado + 1;
            ELSE

              BEGIN
                SELECT 1
                INTO v_estaciudad
                FROM poblaciones
                WHERE cprovin = t_tmp_array(17)
                AND cpoblac = t_tmp_array(18);
              EXCEPTION
                WHEN OTHERS THEN
                  v_estaciudad := 0;
                  p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS',1,'EXCEPCION SELECT VALIDA DEPTO ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, Sqlerrm);
              END;

              IF NVL(v_estaciudad,0) <> 1 THEN
                vr_observaciones := vr_observaciones ||'  El campo Ciudad del Asegurado no existe o no pertenece al departamento.';
                v_resultado := v_resultado + 1;
              END IF;
            END IF;
          END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '10081 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
          -- Valida que el telefono fijo sea numerico
          IF (t_tmp_array(19) != '' OR t_tmp_array(19) IS NOT NULL ) THEN

            BEGIN
              SELECT COUNT(*)
              INTO val_numero
              FROM dual 
              WHERE REGEXP_LIKE (t_tmp_array(19), '^[0-9]+$');
            EXCEPTION
              WHEN OTHERS THEN
                p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS',1,'EXCEPCION SELECT VALIDA TEL FIJO ', Sqlerrm);
            END;

            IF val_numero = 0 THEN

              vr_observaciones := vr_observaciones ||'  El campo Telefono Fijo del Asegurado '|| PAC_MSV_CONSTANTES.c_comp_formato;
              v_resultado := v_resultado + 1;
            END IF;
          END IF;

          -- Valida que el telefono movil sea numerico
          IF v_traecel THEN
          IF (t_tmp_array(20) != '' OR t_tmp_array(20) IS NOT NULL) THEN
            BEGIN
              SELECT COUNT(*)
              INTO val_numero
              FROM dual 
              WHERE REGEXP_LIKE (t_tmp_array(20), '^[0-9]+$');
            EXCEPTION
              WHEN OTHERS THEN
                p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS',1,'EXCEPCION SELECT VALIDA TEL MOVIL ', Sqlerrm);
            END;

            IF val_numero = 0 THEN

              vr_observaciones := vr_observaciones ||'  El campo Telefono Movil del Asegurado '|| PAC_MSV_CONSTANTES.c_comp_formato;
              v_resultado := v_resultado + 1;
            END IF;
          END IF;
          END IF;
          -- FIN - 11/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS', 111, '10123 PR_VALIDA_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, Sqlerrm);
        --TIPO CARGUE DE EXCLUCIONES.   
        ELSIF (UPPER(t_tmp_array(13)) = 'EX') THEN

          IF (t_tmp_array(4) != '' OR t_tmp_array(4) IS NOT NULL) THEN
            IF t_tmp_array(4) = 'TI' THEN      v_tipo_doc := 34;
            ELSIF t_tmp_array(4) = 'CC' THEN   v_tipo_doc := 36;
            ELSIF t_tmp_array(4) = 'NIT' THEN  v_tipo_doc := 37;
            ELSIF t_tmp_array(4) = 'RC' THEN   v_tipo_doc := 35;
            ELSIF t_tmp_array(4) = 'CE' THEN   v_tipo_doc := 33;
            ELSIF t_tmp_array(4) = 'PA' THEN   v_tipo_doc := 40;
            ELSIF t_tmp_array(4) = 'DE' THEN   v_tipo_doc := 42;
            ELSIF t_tmp_array(4) = 'CD' THEN   v_tipo_doc := 44;
            ELSIF t_tmp_array(4) = 'NA' THEN  v_tipo_doc := 0;
            -- INICIO - Company - 07/04/2021 - Ar 39653 - Validacion tipo documento numero unico identificacion
            ELSIF t_tmp_array(4) = 'NUIP' THEN  v_tipo_doc := 38;
            -- FIN - Company -  07/04/2021 - Ar 39653 - Validacion tipo documento numero unico identificacion
            -- INICIO - Company - 04/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
--INICIO 14.0
            -- INICIO - Company - 31/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
            --ELSIF t_tmp_array(4) = 'N A' THEN  v_tipo_doc2 := 0;  
            --Ini Company(LARO) 28112020 Factura Electronica
              --ELSIF t_tmp_array(4) = 'N A' THEN  v_tipo_doc := 0;
              ELSIF t_tmp_array(4) = 'N A' THEN  
              BEGIN
                 SELECT CRESPUE
                   INTO v_pregun535
                   FROM PREGUNPOLSEG 
                  WHERE SSEGURO = (SELECT SSEGURO FROM SEGUROS WHERE NPOLIZA = v_poliza AND NCERTIF = 0)
                    AND CPREGUN = 535 
                    AND NMOVIMI = (SELECT MAX(NMOVIMI)
                                     FROM PREGUNPOLSEG 
                                    WHERE SSEGURO = (SELECT SSEGURO FROM SEGUROS WHERE NPOLIZA = v_poliza AND NCERTIF = 0)
                                      AND CPREGUN = 535);
              EXCEPTION
                WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM SEGUROS. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
              END;
                 --0    =   Asegurado
                 --100  =   Tomador   
                 IF v_pregun535 = 0 THEN
                    vr_observaciones := vr_observaciones || PAC_MSV_CONSTANTES.c_tipo_identificacion || ',';
                    v_resultado := v_resultado + 1;
                 ELSE
                    v_tipo_doc := 0; 
                 END IF;

              --Fin Company(LARO) 28112020 Factura Electronica
            -- FIN - Company - 31/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
--FIN 14.0
            ELSE 
              vr_observaciones := vr_observaciones ||'  El campo tipo de documento '|| PAC_MSV_CONSTANTES.c_tipo_identificacion || ',';
              v_resultado := v_resultado + 1;
            -- FIN - Company - 04/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
            END IF;
            IF (f_buscar_no_imprimible(t_tmp_array(4)) >= 1) THEN
              vr_estado := 'NO';
              vr_observaciones := vr_observaciones ||'  El campo tipo de documento '|| PAC_MSV_CONSTANTES.c_caract_especiales || ',';
              v_resultado := v_resultado + 1;
            END IF;
          ELSE
            vr_observaciones := vr_observaciones ||'  El campo tipo de documento es '|| PAC_MSV_CONSTANTES.c_camp_obligatorio || ',';
            v_resultado := v_resultado + 1;
          END IF;
          IF(v_tipo_doc = 40) THEN
            IF (t_tmp_array(5) != '' OR t_tmp_array(5) IS NOT NULL) THEN
            v_con_aseg := 0;
            IF (f_buscar_imprimible_letra_numero(t_tmp_array(5)) >= 1) THEN
              vr_observaciones := vr_observaciones ||'  El campo numero documento '|| PAC_MSV_CONSTANTES.c_comp_formato || ',';
              v_resultado := v_resultado + 1;
              ELSE
                -- INICIO - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
                BEGIN
                  SELECT COUNT( 1 )
                    INTO v_con_aseg
                    FROM asegurados a
                    JOIN seguros s on s.sseguro = a.sseguro
                    JOIN per_personas pp on pp.sperson = a.sperson
                   WHERE s.sseguro in (SELECT SSEGURO FROM SEGUROS WHERE npoliza = v_poliza and ncertif <>0)
                     AND pp.ctipide  = v_tipo_doc
                     AND pp.nnumide = t_tmp_array(5);
                EXCEPTION
                  WHEN OTHERS THEN
                    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS',1,'EXCEPCION SELECT ASEGURADOS: ' || Sqlerrm, Sqlerrm);
                END;
                /*
                FOR z IN (SELECT SSEGURO FROM SEGUROS WHERE NPOLIZA = v_poliza AND NCERTIF != 0)
                LOOP
                  SELECT NNUMIDE INTO v_documen_ex  FROM PER_PERSONAS pe WHERE pe.sperson = (SELECT SPERSON FROM ASEGURADOS WHERE SSEGURO = z.sseguro);
                  SELECT CTIPIDE INTO v_tipo_doc_ex FROM PER_PERSONAS pr WHERE pr.sperson = (SELECT SPERSON FROM ASEGURADOS WHERE SSEGURO = z.sseguro);
                  IF (v_documen_ex = t_tmp_array(5) AND v_tipo_doc_ex = v_tipo_doc) THEN
                      v_con_aseg := 1;
                  END IF;
                END LOOP;
                */
                --IF (v_con_aseg = 0) THEN 
                IF nvl(v_con_aseg,0) = 0 THEN 
                -- FIN - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
                   vr_observaciones := vr_observaciones ||' '|| PAC_MSV_CONSTANTES.c_aseg_no_registrado || ',';
                   v_resultado := v_resultado + 1;
                END IF;
            END IF;
          ELSE
            -- INICIO - Company - 04/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
            -- Si el tipo de documento es diferente a N A o NA entonces debe ser obligatorio el numero de documento
            IF v_tipo_doc <> 0 THEN
            -- FIN - Company - 04/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
            vr_observaciones := vr_observaciones ||'  El campo numero documento es '|| PAC_MSV_CONSTANTES.c_camp_obligatorio || ',';
            v_resultado := v_resultado + 1;
            -- INICIO - Company - 04/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
            END IF;
            -- FIN - Company - 04/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
          END IF;

          --OTROS TIPOS DE DOCUMENTOS.
          ELSE
          IF (t_tmp_array(5) != '' OR t_tmp_array(5) IS NOT NULL) THEN
              v_con_aseg := 0;
            IF (f_buscar_no_imprimible_letra(t_tmp_array(5)) >= 1) THEN
              vr_observaciones := vr_observaciones ||'  El campo numero documento '|| PAC_MSV_CONSTANTES.c_comp_formato || ',';
              v_resultado := v_resultado + 1;

              ELSE
                -- INICIO - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
                BEGIN
                  SELECT COUNT( 1 )
                    INTO v_con_aseg
                    FROM asegurados a
                    JOIN seguros s on s.sseguro = a.sseguro
                    JOIN per_personas pp on pp.sperson = a.sperson
                   WHERE s.sseguro in (SELECT SSEGURO FROM SEGUROS WHERE npoliza = v_poliza and ncertif <>0 and csituac <> 2)
                     AND pp.ctipide  = v_tipo_doc
                     AND pp.nnumide = t_tmp_array(5);
                EXCEPTION
                  WHEN OTHERS THEN
                    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS',1,'EXCEPCION SELECT ASEGURADOS: ' || Sqlerrm, Sqlerrm);
                END;
                /*
                FOR z IN (SELECT SSEGURO FROM SEGUROS WHERE NPOLIZA = v_poliza AND NCERTIF != 0 AND CSITUAC != 2)
                LOOP
                  -- INICIO - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
                  BEGIN
                  -- FIN - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
                  SELECT NNUMIDE INTO v_documen_ex  FROM PER_PERSONAS pe WHERE pe.sperson = (SELECT SPERSON FROM ASEGURADOS WHERE SSEGURO = z.sseguro);
                  -- INICIO - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
                  EXCEPTION
                    WHEN OTHERS THEN
                      NULL;
                  END;
                  -- FIN - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
                  -- INICIO - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
                  BEGIN
                  -- FIN - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
                  SELECT CTIPIDE INTO v_tipo_doc_ex FROM PER_PERSONAS pr WHERE pr.sperson = (SELECT SPERSON FROM ASEGURADOS WHERE SSEGURO = z.sseguro);
                  -- INICIO - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
                  EXCEPTION
                    WHEN OTHERS THEN
                      NULL;
                  END;
                  -- FIN - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
                  IF (v_documen_ex = t_tmp_array(5) AND v_tipo_doc_ex = v_tipo_doc) THEN
                      v_con_aseg := 1;
                  END IF;
                END LOOP;
                */
                --IF (v_con_aseg = 0) THEN 
                IF NVL(v_con_aseg,0) = 0 THEN 
                -- FIN - 21/09/2020 - Company - AR 37224 - Incidencias HU-EMI-PW-APGP-014
                   vr_observaciones := vr_observaciones ||' '|| PAC_MSV_CONSTANTES.c_aseg_no_registrado || ',';
                   v_resultado := v_resultado + 1;
                END IF;
            END IF;
          ELSE
            vr_observaciones := vr_observaciones ||'  El campo numero documento es '|| PAC_MSV_CONSTANTES.c_camp_obligatorio || ',';
            v_resultado := v_resultado + 1;
          END IF;
          END IF;
           IF (t_tmp_array(5) != '' OR t_tmp_array(5) IS NOT NULL) THEN
            IF (f_buscar_no_imprimible_letra(t_tmp_array(5)) = 0) THEN
              IF(v_con_aseg = 1) THEN
                BEGIN
                SELECT CSITUAC INTO v_anulado FROM SEGUROS 
                 WHERE SSEGURO = 
                 (SELECT SSEGURO FROM ASEGURADOS WHERE SPERSON = 
                 (SELECT SPERSON FROM PER_PERSONAS WHERE NNUMIDE = TO_CHAR(t_tmp_array(5)) AND CTIPIDE = v_tipo_doc) 
                 AND SSEGURO IN 
                 (SELECT SSEGURO FROM SEGUROS WHERE NPOLIZA = v_poliza AND NCERTIF != 0));
                EXCEPTION
                  WHEN OTHERS THEN
                    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM SEGUROS. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
                END;
               ELSE
                 v_anulado := 0;
               END IF;
            END IF;
          END IF;
          IF (v_anulado != '' OR v_anulado IS NOT NULL) THEN
            IF(v_anulado = 2) THEN
              vr_observaciones := vr_observaciones ||' El Asegurado ya ha sido excluido,';
              v_resultado := v_resultado + 1;
            END IF;
          END IF;
          IF (t_tmp_array(6) != '' OR t_tmp_array(6) IS NOT NULL) THEN
            IF (f_buscar_no_imprimible(t_tmp_array(6)) >= 1) THEN
              vr_observaciones := vr_observaciones ||'  El campo genero '|| PAC_MSV_CONSTANTES.c_caract_especiales || ',';
              v_resultado := v_resultado + 1;
            END IF;
            IF(t_tmp_array(6) != 'M' AND t_tmp_array(6) != 'F') THEN 
                vr_observaciones := vr_observaciones ||'  El campo genero debe de ser F(Femenino) o M(Masculino),';
                v_resultado := v_resultado + 1;
              END IF;
          END IF;
          IF (t_tmp_array(7) != '' OR t_tmp_array(7) IS NOT NULL) THEN
             v_date := NULL;

              begin
                select to_date(t_tmp_array(7),'DD/MM/YYYY') into v_date from dual;
                v_cumple :=0;
                exception when others then 
                v_cumple := 1;
              end;
            IF (v_cumple != 0) THEN
              vr_observaciones := vr_observaciones ||'  El campo fecha de nacimiento '|| PAC_MSV_CONSTANTES.c_comp_formato || ',';
              v_resultado := v_resultado + 1;
            END IF;
          END IF;
          IF (t_tmp_array(8) != '' OR t_tmp_array(8) IS NOT NULL) THEN

            v_date := NULL;
              begin
                select to_date(t_tmp_array(8),'DD/MM/YYYY') into v_date from dual;
                v_cumple :=0;
                exception when others then 
                v_cumple := 1;
              end;
            IF (v_cumple != 0) THEN
              vr_observaciones := vr_observaciones ||'  El campo fecha efecto novedad '|| PAC_MSV_CONSTANTES.c_comp_formato || ',';
              v_resultado := v_resultado + 1;            
              ELSE
                BEGIN
                select COUNT(*) INTO v_aegurado from asegurados where sperson in
                (select sperson from per_personas where nnumide = TO_CHAR(t_tmp_array(5)) 
                and ctipide = v_tipo_doc)and sseguro in(select sseguro from seguros 
                where npoliza = TO_CHAR(v_poliza) and ncertif <> 0);
                EXCEPTION
                  WHEN OTHERS THEN
                    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM ASEGURADOS. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
                END;

                IF (v_aegurado = 1) THEN 
                  select SSEGURO INTO v_seguro from asegurados where sperson in
                  (select sperson from per_personas where nnumide = TO_CHAR(t_tmp_array(5)) 
                  and ctipide = v_tipo_doc)and sseguro in(select sseguro from seguros 
                  where npoliza = TO_CHAR(v_poliza) and ncertif <> 0);
                  -- INICIO - 26/03/2021 - Company - Ar 39558 Validacion de fecha de exclusion anterior a fecha efecto inclusion asegurado
                  BEGIN
                  SELECT TO_CHAR(FEFECTO, 'dd/mm/yyyy') 
                  INTO v_fec_ini 
                  FROM SEGUROS 
                  WHERE SSEGURO = (
                                    SELECT sseguro FROM asegurados WHERE sperson in (
                                                                                       SELECT sperson FROM per_personas WHERE nnumide = TO_CHAR(t_tmp_array(5))
                                                                                    )
                                                                    AND sseguro in (select sseguro from seguros where npoliza = v_poliza and ncertif <>0)
                                  )
                  AND npoliza = v_poliza 
                  AND ncertif <> 0;
                  EXCEPTION
                  WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM SEGUROS. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
                  END;
                  IF( TO_DATE(t_tmp_array(8),'dd/mm/rr') <  to_date(v_fec_ini,'dd/mm/rr') ) THEN 
                    vr_observaciones := vr_observaciones ||' '|| ' Fecha de exclusion no puede ser menor a la fecha de inclusion del asegurado ' || ',';
                    v_resultado := v_resultado + 1;
                  END IF;
                  -- FIN - 26/03/2021 - Company - Ar 39558 Validacion de fecha de exclusion anterior a fecha efecto inclusion asegurado
                  BEGIN
-- 03/03/2021
                  --SELECT TO_CHAR(FEFECTO, 'dd/mm/yyyy') INTO v_fec_ini FROM SEGUROS WHERE SSEGURO = v_seguro;
                  SELECT TO_CHAR(FEFECTO, 'dd/mm/yyyy') INTO v_fec_ini FROM SEGUROS WHERE SSEGURO = (select sseguro from seguros where npoliza= v_poliza and ncertif = 0);
-- 03/03/2021
                  EXCEPTION
                    WHEN OTHERS THEN
                      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM SEGUROS. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
                  END;
                  BEGIN
-- 03/03/2021
                  SELECT TO_CHAR(NVL(s.fvencim, s.fcaranu), 'dd/mm/yyyy') ffinpol INTO v_fec_fin
                  --FROM SEGUROS s WHERE SSEGURO = v_seguro;
                  FROM SEGUROS s WHERE SSEGURO = (select sseguro from seguros where npoliza= v_poliza and ncertif = 0);
-- 03/03/2021
                  EXCEPTION
                    WHEN OTHERS THEN
                      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM SEGUROS. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
                  END;

                  IF(v_date NOT BETWEEN v_fec_ini AND v_fec_fin) THEN 
                    vr_observaciones := vr_observaciones ||' '|| PAC_MSV_CONSTANTES.c_fec_ingre_vigencia || ',';
                    v_resultado := v_resultado + 1;
                  END IF;
                END IF;

            END IF;
          ELSE
            vr_observaciones := vr_observaciones ||'  El campo fecha efecto novedad es '|| PAC_MSV_CONSTANTES.c_camp_obligatorio || ',';
            v_resultado := v_resultado + 1;
          END IF;

          IF (t_tmp_array(9) != '' OR t_tmp_array(9) IS NOT NULL) THEN

            BEGIN
              SELECT COUNT(*)
              INTO val_numero
              FROM dual 
              WHERE REGEXP_LIKE (t_tmp_array(9), '^[0-9]+$');
            EXCEPTION
              WHEN OTHERS THEN
                p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_VALIDA_POS',1,'EXCEPCION SELECT VALIDA PLAN ', Sqlerrm);
            END;

            IF val_numero = 0 THEN
              vr_observaciones := vr_observaciones ||'  El campo plan '|| PAC_MSV_CONSTANTES.c_comp_formato;
              v_resultado := v_resultado + 1;
            END IF;


          IF (f_buscar_no_imprimible_letra(t_tmp_array(9)) >= 1) THEN
              vr_observaciones := vr_observaciones ||'  El campo plan '|| PAC_MSV_CONSTANTES.c_comp_formato || ',';
              v_resultado := v_resultado + 1;
              ELSE
              BEGIN
                SELECT SSEGURO INTO v_seguro FROM SEGUROS WHERE NPOLIZA = v_poliza AND NCERTIF = 0;
              EXCEPTION
                WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM SEGUROS. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
              END;
              BEGIN
              SELECT COUNT(*) INTO v_con_plan FROM RIESGOS WHERE SSEGURO = v_seguro AND NRIESGO = t_tmp_array(9);
              EXCEPTION
                WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error SELECT FROM RIESGOS. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
              END;

              IF (v_con_plan < 1) THEN
              -- INICIO - 20/01/2021 Ar 38616
              --vr_observaciones := vr_observaciones || PAC_MSV_CONSTANTES.c_plan_noexiste|| v_con_plan || ',';
              vr_observaciones := vr_observaciones || PAC_MSV_CONSTANTES.c_plan_noexiste || ',';
              -- FIN - 20/01/2021 Ar 38616
              v_resultado := v_resultado + 1;
              END IF;
            END IF;

          END IF;
            IF (t_tmp_array(10) != '' OR t_tmp_array(10) IS NOT NULL) THEN
            IF (f_buscar_imprimible_letra_numero(t_tmp_array(10)) >= 1) THEN
              vr_observaciones := vr_observaciones ||'  El campo codigo '|| PAC_MSV_CONSTANTES.c_caract_especiales || ',';
              v_resultado := v_resultado + 1;
            END IF;
          END IF;
          IF (t_tmp_array(11) != '' OR t_tmp_array(11) IS NOT NULL) THEN
            IF (f_buscar_imprimible_letra_numero(t_tmp_array(11)) >= 1) THEN
              vr_observaciones := vr_observaciones ||'  El campo curso o sede '|| PAC_MSV_CONSTANTES.c_caract_especiales || ',';
              v_resultado := v_resultado + 1;
            END IF;
          END IF;
          IF (t_tmp_array(12) != '' OR t_tmp_array(12) IS NOT NULL) THEN
            IF (f_buscar_imprimible_correo(t_tmp_array(12)) >= 1) THEN
              vr_observaciones := vr_observaciones ||'  El campo Correo Electronico del Asegurado '|| PAC_MSV_CONSTANTES.c_caract_especiales;
              v_resultado := v_resultado + 1;
            END IF;   
          END IF ;
          IF (t_tmp_array(14) != '' OR t_tmp_array(14) IS NOT NULL) THEN
            IF (f_buscar_imprimible_letra_numero(t_tmp_array(14)) >= 1) THEN
              vr_observaciones := vr_observaciones ||'  El campo Motivo de anulacion'|| PAC_MSV_CONSTANTES.c_caract_especiales;
              v_resultado := v_resultado + 1;
              ELSE
              IF(t_tmp_array(14) != '310' AND t_tmp_array(14) != '346' )THEN 
                vr_observaciones := vr_observaciones ||'  El campo Motivo de anulacion de ser 310 o 346';
                v_resultado := v_resultado + 1;
              END IF;
            END IF;
            ELSE
              vr_observaciones := vr_observaciones ||'  El campo Motivo de anulacion '|| PAC_MSV_CONSTANTES.c_camp_obligatorio;
              v_resultado := v_resultado + 1;
          END IF ;
        END IF;      
      END IF;
    ELSE
      vr_observaciones := vr_observaciones ||'  El campo Tipo de Novedad es '|| PAC_MSV_CONSTANTES.c_camp_obligatorio;
      v_resultado := v_resultado + 1;
    END IF;

    IF (v_resultado >= 1) THEN 

        v_rcermal := v_rcermal + 1;
        vr_estado := 'NO';
      ELSE

        vr_estado := 'OK';
      END IF;

    P_ACTUALIZA_MSV_TB_CARGUE_MASIVO_DET(x.id_cargue,x.nro_linea,vr_estado,vr_observaciones);

    v_resultado := 0;
    vr_observaciones := '';
    vr_estado := '';
    v_conta := 0;
    v_cont_plan := 0;
    v_con_aseg := 0;
    v_anulado := 0;
    v_con_aseg_pre := 0;
    END LOOP;

    IF (v_rcermal<> 0) THEN

--inicio 4.0
      BEGIN
      UPDATE MSV_TB_CARGUE_MASIVO
        SET TOTAL_FALLIDOS = v_rcermal
            ,ESTADO_CARGUE = pac_msv_constantes.c_estado_cargue_inconsistente
--12.0
            ,ESTADO_PROCESO = pac_msv_constantes.c_estado_cargue_terminado
--12.0
--INICIO 14.0
            ,fecha_modificacion = current_timestamp		
--FIN 14.0
        WHERE ID = p_id_cargue;
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error UPDATE MSV_TB_CARGUE_MASIVO. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , SQLERRM);
      END;
--fin 4.0																								 
      RETURN 1;
    ELSE

      RETURN 0;
    END IF;

   EXCEPTION
    --12.0
      WHEN OTHERS THEN
		  UPDATE MSV_TB_CARGUE_MASIVO
			SET 
				ESTADO_PROCESO = pac_msv_constantes.c_estado_cargue_terminado
	--12.0
			WHERE ID = p_id_cargue;
			COMMIT;
         -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
         -- RETURN 9999;
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_valida_pos', 2,'Error pr_valida_pos.: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || dbms_utility.format_call_stack , SQLERRM);
         RETURN 1;
         -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
   END pr_valida_pos;

--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB   
---
PROCEDURE pr_procesa_cargue_pos(p_id_cargue_in              IN  MSV_TB_CARGUE_MASIVO.id%TYPE)  IS
p_indicador_proceso_out  VARCHAR2(4000);
p_observacion_proceso_out  VARCHAR2(4000);
p_id_cargue_in2 NUMBER;
N               NUMBER;
nTIPO           NUMBER;
NNPOLIZA        NUMBER;
CAM18           VARCHAR2(4000);
num_err         NUMBER;
psproces        NUMBER ;
Vsseguro        NUMBER;
VCAGENTE        NUMBER;
pfemisio        date := sysdate;
pfvencimi       date := sysdate;
pctiprec        NUMBER := 0;
pnanuali        NUMBER ;
pnfracci        NUMBER ;
pccobban        NUMBER ;
pcestimp        NUMBER ;
num_recibo      NUMBER ;
pmodo           VARCHAR2(4000) := 'R';
pcmovimi        NUMBER ;
pnmovimi        NUMBER ; 
pfefecto        date := sysdate;
xcforpag_rec    NUMBER := 1; 
pttabla         VARCHAR2(4000);
pfuncion        VARCHAR2(4000) := 'CAR';
pcdomper        NUMBER := 0; 
TOTALPRIMAF     NUMBER ; 
TOTALPRIMAFEX   NUMBER ; 
NONRECIBO       NUMBER ; 
ffecextini       DATE:= sysdate; 
ffecextfin       DATE:= sysdate;
vcctiprec        NUMBER := 9;
v_tipocert       VARCHAR2(20);
nnrecibo         NUMBER;
VCTX NUMBER;
NCONTAR NUMBER := 0;
--- INICIO PYALLTIT  06062020
nSqlerrm     NUMBER;
nSqlCode     VARCHAR2(4000);
nCSITUAC     SEGUROS.CSITUAC%TYPE;
nnPolizaSit  NUMBER;
vnumerr      NUMBER;
nMovi        NUMBER;
dFCARPRO     DATE;
nIndicadorIN NUMBER := 0;
nIndicadorEX NUMBER := 0;
FFVENCIM     DATE;
FFechaingresopoliza_I DATE;
NNRECUNIF_I NUMBER;
FFechaingresopoliza DATE;
NNRECUNIF NUMBER;
nCSITUAC_I  NUMBER;
--- FIN PYALLTIT  06062020
--- INICIO PYALLTIT  14042020
nsproduc_pos NUMBER;
nExisteRetorno NUMBER := 0;
--- FIN PYALLTIT  14042020				  
-- INICIO DML
nReciboPor pregunpolseg.CRESPUE%type;
-- FIN DML
-- INICIO -  29/08/2020 - Company - AR 37070 - Incidencias HU-EMI-PW-APGP-012
v_procesado  NUMBER := 0;
-- FIN -  29/08/2020 - Company - AR 37070 - Incidencias HU-EMI-PW-APGP-012
--  INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
v_ctipcom         NUMBER;
v_iprianu         NUMBER;
v_concep          NUMBER;
v_coacedido       NUMBER;
v_tienecoaseg     NUMBER;
v_sseguro_0       NUMBER;
v_comisi          NUMBER;
v_cforpag         NUMBER;
v_concep_cb       NUMBER;
v_coadev          NUMBER; 
v_comdev          NUMBER;
v_porcprim        NUMBER;
nPlan             NUMBER;
--  FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
-- INICIO - 11/09/2020 - Company - AR 37166 - Incidencias HU-EMI-APGP-004
vprimrecibo       NUMBER;
vresul            NUMBER;
vrecibok          NUMBER;
-- FIN - 11/09/2020 - Company - AR 37166 - Incidencias HU-EMI-APGP-004
--Ini Company(LARO) 28112020 Factura Electronica
v_pregun535       NUMBER;
V_TDOMICI         VARCHAR2(100);  
V_TDOMICI_CERO    VARCHAR2(100);  
V_CPOBLAC_CERO    NUMBER;
V_CPROVIN_CERO    NUMBER;  
V_TVALCON_CERO    VARCHAR(100); 
V_TVALCON_CERT    VARCHAR(100);   
V_SPERSON_CERT    NUMBER;
--Fin Company(LARO) 28112020 Factura Electronica
-- INICIO - 07/01/2021 Ar 37659
v_fefecto_carga   DATE;
v_sseguro_dm      NUMBER;
v_nmovimi_dm      NUMBER;
-- FIN - 07/01/2021 Ar 37659
-- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
v_fcarant         DATE;
-- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
-- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
v_cmodcon         NUMBER;
-- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
-- INICIO - 16/04/2021 Ar 37659
pnmovimi_rec      NUMBER;
v_fefectoex       DATE;
v_hayinclusiones  NUMBER;
v_sseguro_cert    seguros.sseguro%TYPE;
v_nmovimi_cert    movseguro.nmovimi%TYPE;
-- FIN - 16/04/2021 Ar 37659
BEGIN
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '10687 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
  -- INICIO - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP
  v_idcargue := p_id_cargue_in;
  v_sproces  := SPROCES.NEXTVAL;
  -- FIN - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP

p_id_cargue_in2 := 1;
BEGIN
SELECT NPOLIZA
INTO   NNPOLIZA
FROM   MSV_TB_CARGUE_MASIVO
WHERE ID = p_id_cargue_in;
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, 'EXCEPCION SELECT MSV_TB_CARGUE_MASIVO(1) ', nSqlerrm);
END;

BEGIN
UPDATE MSV_TB_CARGUE_MASIVO_DET
SET TEXTO = NNPOLIZA||PAC_MSV_CONSTANTES.c_caracter_coma||TEXTO
WHERE ID = p_id_cargue_in
AND   ID_CARGUE = p_id_cargue_in;
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, 'EXCEPCION UPDATE MSV_TB_CARGUE_MASIVO_DET(1) ', nSqlerrm);
END;

BEGIN
UPDATE MSV_TB_CARGUE_MASIVO_DET
SET TEXTO = SUBSTR(TEXTO,1,LENGTH(TEXTO))||'0'
WHERE ID = p_id_cargue_in
AND   ID_CARGUE = p_id_cargue_in
AND  INSTR(TEXTO,';IN;') <> 0;
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, 'EXCEPCION UPDATE MSV_TB_CARGUE_MASIVO_DET(1) ', nSqlerrm);
END;
--
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '10734 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
PAC_POS_CARGUE.pr_procesa_cargue_masivo(p_id_cargue_in,'AS',USER,p_indicador_proceso_out,p_observacion_proceso_out);
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '10736 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
COMMIT;

FOR Z IN(SELECT ROWID  FROM INT_CARGA_GENERICO
        WHERE PROCESO = p_id_cargue_in
        AND   NCARGA  =  p_id_cargue_in
        AND   TIPO_OPER = 'AS') LOOP
    nContar := NVL(nContar,0) + 1;
    update INT_CARGA_GENERICO
    set NLINEA = nContar
    where PROCESO   =  p_id_cargue_in
    AND   NCARGA    =  p_id_cargue_in
    AND   TIPO_OPER = 'AS'
    AND   ROWID = Z.ROWID;
COMMIT;
END LOOP;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '10752 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
  BEGIN
    -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
    --select sseguro ,CAGENTE,DECODE(CFORPAG,0,1,CFORPAG),FCARPRO,FCARANT,FVENCIM, CSITUAC,sproduc --- INICIO PYALLTIT  06062020
    select sseguro ,CAGENTE,DECODE(CFORPAG,0,1,CFORPAG),FCARPRO,NVL(FCARANT,FCARPRO),FVENCIM, CSITUAC,sproduc --- INICIO PYALLTIT  06062020
       INTO Vsseguro , VCAGENTE,xcforpag_rec,dFCARPRO,v_fcarant,FFVENCIM,nCSITUAC_I, nsproduc_pos
    -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
       from seguros where npoliza = NNPOLIZA and ncertif = 0 ;
  EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, 'EXCEPCION SELECT SEGUROS ', nSqlerrm);
  END;

       -- INICIO PYALLTIT 15072020 
       IF pac_retorno.f_tiene_retorno(NULL, Vsseguro, NULL, 'SEG') = 1 THEN
          nExisteRetorno := 1;
       ELSE
          nExisteRetorno := 0;
       END IF;
       -- FIN PYALLTIT 15072020				   
       -- INICIO 5.0 DML 08/07/2020 No se crea recibo si la pregunta Recibo por:(535) es por asegurado. 
       BEGIN
           SELECT CRESPUE
           INTO nReciboPor
           FROM PREGUNPOLSEG 
           WHERE SSEGURO = Vsseguro 
           AND CPREGUN = 535 
           AND NMOVIMI = (SELECT MAX(NMOVIMI)
                            FROM PREGUNPOLSEG 
                           WHERE SSEGURO = Vsseguro 
                             AND CPREGUN = 535);
       EXCEPTION 
       WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 1, '10859 EXCEPTION SELECT PREGUNPOLSEG Vsseguro: ' || Vsseguro || ' nReciboPor: ' || nReciboPor, SQLERRM);
         nReciboPor := 100;-- Si da error toma como si fuera por tomador
       END;
       -- FIN 5.0 DML 08/07/2020 No se crea recibo si la pregunta Recibo por:(535) es por asegurado. 
      
      -- INICIO - 16/04/2021 Ar 37659
      BEGIN
        SELECT COUNT(CAMPO16)
          INTO v_hayinclusiones
          FROM INT_CARGA_GENERICO 
         WHERE PROCESO = p_id_cargue_in 
           AND CAMPO16 = 'IN';
      EXCEPTION
        WHEN OTHERS THEN
          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION SELECT INT_CARGA_GENERICO ', nSqlerrm);
      END;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '10801 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
     IF v_hayinclusiones > 0 THEN
     -- FIN - 16/04/2021 Ar 37659    
     -- INICIO - 07/01/2021 Ar 37659
     BEGIN
       -- INICIO - 14/04/2021 Ar 37659
       --SELECT MIN(CAMPO10)
       SELECT MIN(TO_DATE(CAMPO10,'DD/MM/RRRR'))
       -- FIN - 14/04/2021 Ar 37659
       INTO v_fefecto_carga
       FROM INT_CARGA_GENERICO
       WHERE PROCESO   =  p_id_cargue_in
       AND   NCARGA    =  p_id_cargue_in
       AND   CAMPO16 = 'IN';
     EXCEPTION
       WHEN OTHERS THEN
         -- INICIO - 16/04/2021 Ar 37659
         BEGIN
           SELECT MIN(TO_DATE(CAMPO10,'DD/MM/RRRR'))
             INTO v_fefecto_carga
             FROM INT_CARGA_GENERICO
            WHERE PROCESO   =  p_id_cargue_in
              AND NCARGA    =  p_id_cargue_in
              AND CAMPO16 = 'EX';
         EXCEPTION
           WHEN OTHERS THEN
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_procesa_cargue_pos', 1, ' ERROR SELECT INT_CARGA_GENERICO p_id_cargue_in: ' || p_id_cargue_in , SQLERRM);
         END;
         -- FIN - 16/04/2021 Ar 37659
     END;
     -- FIN - 07/01/2021 Ar 37659

   IF nCSITUAC_I = 5 THEN
       select max(nmovimi) 
       INTO pnmovimi
       from movseguro 
       where sseguro = (select sseguro from seguros where npoliza = NNPOLIZA and ncertif = 0);
   ELSE
       select max(nmovimi)+ 1 
       INTO pnmovimi
       from movseguro 
       where sseguro = (select sseguro from seguros where npoliza = NNPOLIZA and ncertif = 0);   
     -- INICIO - 07/01/2021 Ar 37659
     v_nmovimi_in := pnmovimi;
     -- FIN - 07/01/2021 Ar 37659

         BEGIN
        INSERT INTO MOVSEGURO (SSEGURO,NMOVIMI,CMOTMOV,FMOVIMI,CMOVSEG,FEFECTO,FCONTAB,CIMPRES,CANUEXT,NSUPLEM,NMESVEN,NANYVEN,NCUACOA,
                    FEMISIO,CUSUMOV,CUSUEMI,CDOMPER,CMOTVEN,NEMPLEADO,COFICIN,CESTADOCOL,FANULAC,CUSUANU,CREGUL,CMOTANUL,CDERECHOSEMI) 
        VALUES (Vsseguro,
                pnmovimi,
        -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
        --'997',to_date(sysdate,'DD/MM/RRRR'),'1',to_date(sysdate,'DD/MM/RRRR'),null,'0',null,
        -- INICIO - 07/01/2021 Ar 37659
        --'997',to_date(sysdate,'DD/MM/RRRR'),'1',dFCARPRO,null,'0',null,
        '997',to_date(sysdate,'DD/MM/RRRR'),'1',v_fefecto_carga,null,'0',null,
        -- FIN - 07/01/2021 Ar 37659
        -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
       (select max(nsuplem)+ 1 from movseguro where sseguro = (select sseguro from seguros where npoliza = NNPOLIZA and ncertif = 0)),
        null,null,null,to_date(sysdate,'DD/MM/RRRR'),'AXIS',null,null,'998',null,'17000','1',null,null,null,null,null);
        COMMIT;
        -- VALUES (psperson_promo, psseguro, 1, pcdomici_promo);
        EXCEPTION
            WHEN OTHERS THEN
             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_procesa_cargue_pos', 1, ' NNPOLIZA: '||NNPOLIZA ||' Vsseguro:'||Vsseguro||' pnmovimi: '||pnmovimi, SQLERRM);
            --   RETURN 110167;
        END;
   END IF;


   -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
   IF TO_DATE(v_fefecto_carga,'DD/MM/RR') >= TO_DATE(v_fcarant,'DD/MM/RR') THEN
     v_fcarant := dFCARPRO;
   END IF;
   -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo

-- INICIO 5.0 DML 08/07/2020 No se crea recibo si la pregunta Recibo por:(535) es por asegurado. 
-- INICIO - 08/04/2021 - Company - Ar 39679 - Inconsistencia fecha efecto recibo caratula
-- IF nReciboPor = 100 THEN
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '10880 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
IF NVL(nReciboPor,100) = 100 THEN 
-- FIN - 08/04/2021 - Company - Ar 39679 - Inconsistencia fecha efecto recibo caratula
    -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
    --num_err := f_insrecibo(Vsseguro, VCAGENTE, pfemisio, pfefecto, dFCARPRO, -- pfvencimi+365,
    -- INICIO - 24/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
    -- INSERTA EL RECIBO DE SUPLEMENTO EN CARATULA POR TOMADOR
    --num_err := f_insrecibo(Vsseguro, VCAGENTE, pfemisio, pfefecto, v_fcarant,
    num_err := f_insrecibo(Vsseguro, VCAGENTE, pfemisio, pfefecto, dFCARPRO,
    -- FIN - 24/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
    -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
                                   -- INICIO - 12/11/2020 - Company - Ar 37845 Incidencias Preproduccion Revision Movimientos PW vs iAXIS
                                   --pctiprec, pnanuali, pnfracci, pccobban, pcestimp, NULL,
                                   1, pnanuali, pnfracci, pccobban, pcestimp, NULL,
                                   -- FIN - 12/11/2020 - Company - Ar 37845 Incidencias Preproduccion Revision Movimientos PW vs iAXIS
                                   num_recibo, pmodo, psproces, pcmovimi, pnmovimi, pfefecto,
                                   'CERTIF0', xcforpag_rec, NULL, pttabla, pfuncion,   
                                   NULL, pcdomper);
    IF num_err <> 0 THEN
      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_procesa_cargue_pos', 1, 'ERROR F_INSRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
    END IF;
    -- INICIO - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP
    BEGIN
      INSERT INTO msv_recibos(id_cargue,proceso,recibo,estado)
      VALUES(v_idcargue, v_sproces, num_recibo, 0);
    EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR INSERT MSV_RECIBOS ', SQLERRM);
    END;
    -- FIN - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP
  BEGIN 
      SELECT count(NRECIBO)
      INTO NONRECIBO
      from MOVRECIBO where NRECIBO = num_recibo;
      UPDATE RECIBOS SET CESTAUX = 1 WHERE SSEGURO IN (VSSEGURO);
      IF NONRECIBO = 0 THEN
      SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(17, 'USER_BBDD')) INTO vctx FROM dual; 
      Insert into MOVRECIBO (SMOVREC,NRECIBO,CUSUARI,SMOVAGR,CESTREC,CESTANT,FMOVINI,FMOVFIN,FCONTAB,FMOVDIA,
                       CMOTMOV,CCOBBAN,CDELEGA,CTIPCOB,FEFEADM,CGESCOB,TMOTMOV) 
            values ((SELECT MAX(SMOVREC) + 1  FROM MOVRECIBO),num_recibo,F_USER,'5231881','0','0',to_date(SYSDATE,'DD/MM/RRRR'),
                    null,to_date(SYSDATE,'DD/MM/RRRR'),to_date(SYSDATE,'DD/MM/RRRR'),null,null,'40',
                    null,to_date(SYSDATE,'DD/MM/RRRR'),null,null);
      END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, 'EXCEPCION MOVRECIBO: ' || nSqlerrm, nSqlerrm);
  END;
END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '10922 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
-- FIN 5.0 DML 08/07/2020 No se crea recibo si la pregunta Recibo por:(535) es por asegurado. 
--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB
FOR X IN(SELECT NLINEA, CAMPO01 pnpoliza, UPPER(TRIM(CAMPO06)) TIPO, CAMPO07 NUMID , CAMPO13  CursoSede,CAMPO10  Fechaingresopoliza,
CAMPO11 PLAN1, CAMPO12  CodigoEst, CAMPO09 FechaNacimiento
-- INICIO - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
, count(*) over () total_filas
-- FIN - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
FROM INT_CARGA_GENERICO
WHERE PROCESO = p_id_cargue_in
AND   NCARGA  =  p_id_cargue_in
AND   TIPO_OPER = 'AS'
AND   CAMPO16 = 'IN'
ORDER BY NLINEA) LOOP
--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB
nIndicadorIN  := 1; --- INICIO PYALLTIT  06062020
PAC_POS_CARGUE.nSede := X.CursoSede;
PAC_POS_CARGUE.nCodigoEst  := X.CodigoEst;
PAC_POS_CARGUE.dFechaIngreso := X.Fechaingresopoliza;
/*
TI	Tarjeta identidad	34
CC	Cedula Ciudadania 36
RC	Registro civil	35
CE	Cedula extranjeria 33
PA	Pasaporte	40 
DE	Documento de Identificacion extranjero 	42
CD	CarneÃ¢â‚¬Å¡Diplomatico 	44
N A	Identificador del sistema (Sin Identificaci) 0
*/

IF X.TIPO = 'TI' THEN      nTIPO := 34;
ELSIF X.TIPO = 'CC' THEN   nTIPO := 36;
ELSIF X.TIPO = 'NIT' THEN   nTIPO := 37;
ELSIF X.TIPO = 'RC' THEN   nTIPO := 35;
ELSIF X.TIPO = 'CE' THEN   nTIPO := 33;
ELSIF X.TIPO = 'PA' THEN   nTIPO := 40;
ELSIF X.TIPO = 'DE' THEN   nTIPO := 42;
ELSIF X.TIPO = 'CD' THEN   nTIPO := 44;
-- INICIO - Company - 07/04/2021 - Ar 39653 - Validacion tipo documento numero unico identificacion
ELSIF X.TIPO = 'NUIP' THEN   nTIPO := 38;
-- FIN - Company - 07/04/2021 - Ar 39653 - Validacion tipo documento numero unico identificacion
--- INICIO PYALLTIT  06062020
ELSIF (X.TIPO = 'N A' OR X.TIPO = 'NA')  AND X.NUMID IS NULL THEN  nTIPO := 0;
-- INICIO - Company - 04/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
-- ELSIF X.TIPO = 'N A' AND X.NUMID IS NOT NULL THEN  nTIPO := 0;
ELSIF (X.TIPO = 'N A' OR X.TIPO = 'NA') AND X.NUMID IS NOT NULL THEN  nTIPO := 0;
-- FIN - Company - 04/08/2020 - AR 36669 - Inconsistencias al validar cargue masivo
--- FIN PYALLTIT  06062020
-- INICIO - Company 27/08/2020 - AR 37035 - Incidencias HU-EMI-APGP-017
ELSE
  CONTINUE;
-- FIN - Company 27/08/2020 - AR 37035 - Incidencias HU-EMI-APGP-017
END IF;
--- INICIO PYALLTIT  06062020
  BEGIN
    PAC_POS_CARGUE.nEDADASEG := TRUNC(SYSDATE) - TO_DATE(X.FechaNacimiento,'DD/MM/RRRR');
  EXCEPTION
          WHEN NO_DATA_FOUND THEN
           PAC_POS_CARGUE.nEDADASEG := 0;
           nSqlerrm     := Sqlerrm;
           nSqlCode     := SqlCode;
            p_tab_error(f_sysdate, f_user, '2 PR_PROCESA_CARGUE_POS nEDADASEG', 111, 'X.FechaNacimiento: '||X.FechaNacimiento ||' pnpoliza:'||X.pnpoliza||' PAC_POS_CARGUE.nEDADASEG: '||PAC_POS_CARGUE.nEDADASEG, nSqlCode||' '||nSqlerrm);
  END;
--- FIN PYALLTIT  06062020
  -- INICIO -  29/08/2020 - Company - AR 37070 - Incidencias HU-EMI-PW-APGP-012-- 37070
  -- Valida si el registro ya se proceso en el mismo id_cargue
  BEGIN
    SELECT COUNT(*)
    INTO v_procesado
    FROM msv_procesados
    WHERE id_cargue = p_id_cargue_in
    AND nnumid = x.numid;
  EXCEPTION
    WHEN OTHERS THEN
      v_procesado := 0;
  END;
  IF v_procesado = 0 THEN
  -- FIN -  29/08/2020 - Company - AR 37070 - Incidencias HU-EMI-PW-APGP-012-- 37070
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '11000 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
N := PAC_POS_CARGUE.f_alta_certif(X.pnpoliza,p_id_cargue_in,nTIPO,X.NUMID,X.NLINEA,X.PLAN1,num_recibo);
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '11002 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
     -- INICIO - 16/04/2021 Ar 37659
     BEGIN
       SELECT sseguro
       INTO v_sseguro_cert
       FROM seguros
       WHERE npoliza = X.pnpoliza
       AND ncertif = v_ncertif;
     EXCEPTION
       WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION SELECT SEGUROS ', sqlerrm);
     END;

     BEGIN
       INSERT INTO detmovsegurocol(sseguro_0, nmovimi_0, sseguro_cert, nmovimi_cert)
                           VALUES (Vsseguro, pnmovimi, v_sseguro_cert, 1 );
     EXCEPTION
       WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION INSERT DETMOVSEGUROCOL INCLUSION Vsseguro: ' || Vsseguro, sqlerrm);
     END;

     -- FIN - 16/04/2021 Ar 37659
  -- INICIO -  29/08/2020 - Company - AR 37070 - Incidencias HU-EMI-PW-APGP-012-- 37070
  IF N = 0 THEN
      INSERT INTO msv_procesados(id_cargue, nnumid, estadoalta)
      VALUES(p_id_cargue_in, x.numid, 'OK');
    END IF;
  ELSE
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'ERROR F_ALTA_CERTIF N: ' || N || ' X.pnpoliza: ' ||
    X.pnpoliza || ' p_id_cargue_in: ' || p_id_cargue_in || ' X.NUMID: ' || X.NUMID || 'X.NLINEA: '|| X.NLINEA || ' num_recibo: ' || num_recibo, Sqlerrm);    
  END IF;

  -- FIN -  29/08/2020 - Company - AR 37070 - Incidencias HU-EMI-PW-APGP-012
-- INICIO - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo

IF x.nlinea = 1 THEN
TVALORDFIN := v_ncertif || ' - ';
-- INICIO - 16/04/2021 Ar 37659
-- INICIO - 16/04/2021 Ar 39815
ELSIF x.nlinea = x.total_filas THEN
--ELSE
--TVALORDFIN := TVALORDFIN || v_ncertif || ' - ';
TVALORDFIN := TVALORDFIN || v_ncertif;
-- INICIO - 16/04/2021 Ar 39815
-- FIN - 16/04/2021 Ar 37659
END IF;
-- FIN - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
COMMIT;
END LOOP;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '11048 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
IF NVL(nIndicadorIN,0)  = 1 THEN --- INICIO PYALLTIT  06062020
    BEGIN
      INSERT INTO DETMOVSEGURO (SSEGURO,NMOVIMI,CMOTMOV,NRIESGO,CGARANT,TVALORA,TVALORD,CPREGUN,CPROPAGASUPL) 
      values (Vsseguro,pnmovimi,
      -- INICIO - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
      '100','0','0',null,SUBSTR(TVALORDFIN,1,1000),'0',null); 
      -- FIN - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
      TVALORDFIN := null;
    EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION INSERT DETMOVSEGURO Vsseguro: ' || Vsseguro, sqlerrm);
        --   RETURN 110167;
    END;
END IF; --- INICIO PYALLTIT  06062020
  TOTALPRIMAF:=0;

      --  INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
      BEGIN
        SELECT sseguro, ctipcom
        INTO v_sseguro_0, v_ctipcom 
        FROM seguros WHERE npoliza = (select npoliza from seguros where sseguro = Vsseguro)
        AND ncertif = 0;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      -- Se obtiene el porcentaje de comision
      v_comisi := PAC_ENVIO_PRODUCCION_COL.F_PRI_COMISION(v_sseguro_0,1,num_recibo,v_ctipcom);
      -- Se obtiene el porcentaje de coaseguro
      BEGIN
        SELECT ploccoa
          INTO v_coacedido
          FROM coacuadro
          WHERE sseguro = v_sseguro_0
          AND ncuacoa = (SELECT MAX(ncuacoa) FROM coacedido WHERE sseguro = v_sseguro_0);
      EXCEPTION
        WHEN OTHERS THEN
          v_coacedido := 0;
      END;
      -- Obtiene el numero del riesgo
      BEGIN
        SELECT crespue
        INTO nPlan
        FROM pregunpolseg
        WHERE cpregun=4089
        AND sseguro = Vsseguro
        AND nmovimi = (select max(nmovimi) from pregunpolseg where sseguro = Vsseguro);
      EXCEPTION
        WHEN OTHERS THEN
          nPlan := 1;
      END;
      --  FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '11101 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
-- INICIO - 11/09/2020 - Company - AR 37166 - Incidencias HU-EMI-APGP-004
num_err:= pac_md_produccion.f_val_primpresup(v_sseguro_0,vresul);
IF NVL(vresul,0) = 1 AND NVL(vrecibok,0) = 0 THEN
BEGIN
SELECT MIN(nrecibo)
INTO vprimrecibo
FROM adm_recunif
WHERE nrecunif = num_recibo;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
--
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '11115 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
FOR O IN (SELECT D.CGARANT,
SUM(D.ICONCEP)IPRIANU, d.cconcep, A.nrecunif
FROM DETRECIBOS D,adm_recunif A
WHERE D.NRECIBO = A.NRECIBO
AND A.NRECIBO = vprimrecibo
AND A.nrecunif = num_recibo
GROUP BY D.CGARANT,d.cconcep, A.nrecunif)LOOP

    num_err := f_insdetrec(num_recibo, --pnrecibo,
                                    -- INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
                                    O.CCONCEP,
                                    O.IPRIANU,
                                    -- FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
                                    NULL, --xploccoa,
                                    O.CGARANT, /*48*/
                                    1,
                                    NULL, --xctipcoa,
                                    NULL, --xcageven_gar,
                                    pnmovimi, --xnmovima_gar,
                                    0, --xccomisi,
                                    Vsseguro,
                                    1,
                                    -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
                                    /*
                                    NULL,
                                    NULL,
                                    NULL,
                                    0 --decimals
                                    );
                                    */
                                    O.IPRIANU,
                                    SYSDATE,
                                    NULL,
                                    0 --decimals
                                    );
                                    IF num_err <> 0 THEN
                                      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 1, 'ERROR F_INSDETRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
                                    END IF;
                                    -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
                                    
   IF o.cconcep = 0 OR o.cconcep = 50 THEN
   TOTALPRIMAF := ROUND(TOTALPRIMAF +  O.IPRIANU);                                  
   END IF;
COMMIT;
END LOOP;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '11161 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
vrecibok := 1;
ELSE 
-- FIN - 11/09/2020 - Company - AR 37166 - Incidencias HU-EMI-APGP-004
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '11165 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
FOR O IN (SELECT D.CGARANT,
SUM(D.ICONCEP)IPRIANU, d.cconcep, A.nrecunif
FROM DETRECIBOS D,adm_recunif A
WHERE D.NRECIBO = A.NRECIBO
AND A.nrecunif = num_recibo
GROUP BY D.CGARANT,d.cconcep, A.nrecunif)LOOP
-- INSERTA DETALLE DE RECIBO AGRUPADOR 
NNRECUNIF_I := O.nrecunif;
-- INICIO 5.0 DML 08/07/2020 No se crea recibo si la pregunta Recibo por:(535) es por asegurado. 
IF NVL(nReciboPor,100) = 100 THEN 

    num_err := f_insdetrec(num_recibo, --pnrecibo,
                                    -- INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
                                    O.CCONCEP,
                                    O.IPRIANU,
                                    -- FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
                                    NULL, --xploccoa,
                                    O.CGARANT, /*48*/
                                    1,
                                    NULL, --xctipcoa,
                                    NULL, --xcageven_gar,
                                    pnmovimi, --xnmovima_gar,
                                    0, --xccomisi,
                                    Vsseguro,
                                    1,
                                    -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
                                    /*
                                    NULL,
                                    NULL,
                                    NULL,
                                    0 --decimals
                                    );
                                    */
                                    O.IPRIANU,
                                    SYSDATE,
                                    NULL,
                                    0 --decimals
                                    );
                                    IF num_err <> 0 THEN
                                      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 1, 'ERROR F_INSDETRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
                                    END IF;
                                    -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo

   -- INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
   IF o.cconcep = 0 OR o.cconcep = 50 THEN
   TOTALPRIMAF := ROUND(TOTALPRIMAF +  O.IPRIANU);                                  
   -- FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
   END IF;
   -- FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
COMMIT;
END IF;
-- FIN 5.0 DML 08/07/2020 No se crea recibo si la pregunta Recibo por:(535) es por asegurado. 
END LOOP;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '11219 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
-- INICIO - 11/09/2020 - Company - AR 37166 - Incidencias HU-EMI-APGP-004
END IF;

-- FIN - 11/09/2020 - Company - AR 37166 - Incidencias HU-EMI-APGP-004
--- INICIO PYALLTIT  06062020
IF NVL(nIndicadorIN,0)  = 1 THEN 
BEGIN
    -- INICIO - 08/04/2021 - Company - Ar 39679 - Inconsistencia fecha efecto recibo caratula
    --SELECT TO_DATE(MIN(CAMPO10),'DD/MM/RRRR')  Fechaingresopoliza
    SELECT MIN(TO_DATE(CAMPO10,'DD/MM/RRRR'))  Fechaingresopoliza
    -- FIN - 08/04/2021 - Company - Ar 39679 - Inconsistencia fecha efecto recibo caratula
    INTO  FFechaingresopoliza_I
    FROM INT_CARGA_GENERICO
    WHERE PROCESO = p_id_cargue_in
    AND   NCARGA  =  p_id_cargue_in
    AND   TIPO_OPER = 'AS'
    AND   CAMPO16 = 'IN';
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION SELECT INT_CARGA_GENERICO ', nSqlerrm);
END;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '11241 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
BEGIN
UPDATE RECIBOS
-- INICIO - 08/04/2021 - Company - Ar 39679 - Inconsistencia fecha efecto recibo caratula
--SET   FEFECTO =  NVL(FFechaingresopoliza_I,ffecextini)
SET   FEFECTO =  FFechaingresopoliza_I
-- FIN - 08/04/2021 - Company - Ar 39679 - Inconsistencia fecha efecto recibo caratula
    -- ,FVENCIM =  FFVENCIM
WHERE NRECIBO =  NNRECUNIF_I;
COMMIT;
EXCEPTION 
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION UPDATE RECIBOS FEFECTO SQLERRM: ' || Sqlerrm, Sqlerrm);
END;
END IF; 
--- FIN PYALLTIT  06062020
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '11257 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
-- INICIO 5.0 DML 08/07/2020 No se crea recibo si la pregunta Recibo por:(535) es por asegurado. 
IF NVL(nReciboPor,100) = 100 THEN 
     BEGIN
       Insert into VDETRECIBOS (NRECIBO,IPRINET,IRECEXT,ICONSOR,IRECCON,IIPS,IDGS,IARBITR,IFNG,IRECFRA,IDTOTEC,IDTOCOM,ICOMBRU,
       ICOMRET,IDTOOM,IPRIDEV,ITOTPRI,ITOTDTO,ITOTCON,ITOTIMP,ITOTALR,IDERREG,ITOTREC,ICOMDEV,IRETDEV,ICEDNET,ICEDREX,ICEDCON,
       ICEDRCO,ICEDIPS,ICEDDGS,ICEDARB,ICEDFNG,ICEDRFR,ICEDDTE,ICEDDCO,ICEDCBR,ICEDCRT,ICEDDOM,ICEDPDV,ICEDREG,ICEDCDV,ICEDRDV,
       IT1PRI,IT1DTO,IT1CON,IT1IMP,IT1REC,IT1TOTR,IT2PRI,IT2DTO,IT2CON,IT2IMP,IT2REC,IT2TOTR,ICOMCIA,ICOMBRUI,ICOMRETI,ICOMDEVI,
       ICOMDRTI,ICOMBRUC,ICOMRETC,ICOMDEVC,ICOMDRTC,IOCOREC,IIMP_1,IIMP_2,IIMP_3,IIMP_4,ICONVOLEODUCTO) 
       values (num_recibo,TOTALPRIMAF,'0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMAF,TOTALPRIMAF,'0','0','0',TOTALPRIMAF,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMAF,'0','0','0','0',TOTALPRIMAF,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');
       COMMIT;
     EXCEPTION
       WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION INSERT VDETRECIBOS ', Sqlerrm);
     END;
     BEGIN
       Insert into VDETRECIBOS_MONPOL (NRECIBO,IPRINET,IRECEXT,ICONSOR,IRECCON,IIPS,IDGS,IARBITR,IFNG,IRECFRA,IDTOTEC,IDTOCOM,
       ICOMBRU,ICOMRET,IDTOOM,IPRIDEV,ITOTPRI,ITOTDTO,ITOTCON,ITOTIMP,ITOTALR,IDERREG,ITOTREC,ICOMDEV,IRETDEV,ICEDNET,ICEDREX,
       ICEDCON,ICEDRCO,ICEDIPS,ICEDDGS,ICEDARB,ICEDFNG,ICEDRFR,ICEDDTE,ICEDDCO,ICEDCBR,ICEDCRT,ICEDDOM,ICEDPDV,ICEDREG,ICEDCDV,
       ICEDRDV,IT1PRI,IT1DTO,IT1CON,IT1IMP,IT1REC,IT1TOTR,IT2PRI,IT2DTO,IT2CON,IT2IMP,IT2REC,IT2TOTR,ICOMCIA,ICOMBRUI,ICOMRETI,
       ICOMDEVI,ICOMDRTI,ICOMBRUC,ICOMRETC,ICOMDEVC,ICOMDRTC,IOCOREC,IIMP_1,IIMP_2,IIMP_3,IIMP_4,ICONVOLEODUCTO) 
       values (num_recibo,TOTALPRIMAF,'0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMAF,TOTALPRIMAF,'0','0','0',TOTALPRIMAF,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMAF,'0','0','0','0',TOTALPRIMAF,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');
     EXCEPTION
       WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION INSERT VDETRECIBOS_MONPOL ', nSqlerrm);
     END;
END IF;
--FIN 5.0 DML 08/07/2020 No se crea recibo si la pregunta Recibo por:(535) es por asegurado. 
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '11285 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
--- INICIO PYALLTIT  14072020
IF nReciboPor = 100 AND NVL(nIndicadorIN,0)  = 1 AND NVL(nExisteRetorno,0) = 1 THEN 

num_err := f_agruparecibo_pos(NNPOLIZA, nsproduc_pos, -- r0.sproduc, 
                                          NVL(FFechaingresopoliza_I,ffecextini), -- r0.fefecto,
                                          f_sysdate, 
                                          17, -- r0.cempres,
                                          NULL, -- t_recibo, 
                                          -- INICIO - 12/11/2020 - Company - Ar 37845 Incidencias Preproduccion Revision Movimientos PW vs iAXIS
                                          --0, -- v_tiprec, 
                                          1, -- v_tiprec, 
                                          -- FIN - 12/11/2020 - Company - Ar 37845 Incidencias Preproduccion Revision Movimientos PW vs iAXIS
                                          1);

COMMIT;
IF num_err <> 0 THEN
  p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'ERROR f_agruparecibo_pos NNPOLIZA: ' || NNPOLIZA || ' num_err: ' || num_err, Sqlerrm);
END IF;
END IF;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '11305 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
--- FIN PYALLTIT  14072020			  
--INI 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB
     -- INICIO - 16/04/2021 Ar 37659
     -- Fin del if de v_hayinclusiones
     END IF;
     -- FIN - 16/04/2021 Ar 37659
-------------------------------------------------------ANULAR POLIZA Y CREA RECIBO DE ANULACION EXTORNO---------------------------------
BEGIN
  SELECT COUNT(CAMPO16)  --- INICIO PYALLTIT  06062020 se cambia de campo18 a campo17 por la emilinacion de una columna en el archivo
    INTO CAM18
    FROM INT_CARGA_GENERICO 
   WHERE PROCESO = p_id_cargue_in 
     AND CAMPO16 = 'EX';  --- INICIO PYALLTIT  06062020 se cambia de campo18 a campo17 por la emilinacion de una columna en el archivo
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION SELECT INT_CARGA_GENERICO ', nSqlerrm);
    --   RETURN 110167;
END;

IF CAM18 <> 0 THEN
  BEGIN
    SELECT MAX(nmovimi)+ 1 
    INTO pnmovimi
    FROM movseguro 
    WHERE sseguro = (SELECT sseguro FROM seguros WHERE npoliza = NNPOLIZA AND ncertif = 0);
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION SELECT MAX NMOVIMI MOVSEGURO EXCLUSION ', nSqlerrm);
  END;
BEGIN

  SELECT MIN(TO_DATE(CAMPO10,'DD/MM/RRRR'))  Fechaingresopoliza
    INTO  v_fefectoex
    FROM INT_CARGA_GENERICO
    WHERE PROCESO = p_id_cargue_in
    AND   NCARGA  =  p_id_cargue_in
    AND   TIPO_OPER = 'AS'
    AND   CAMPO16 = 'EX';
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION SELECT INT_CARGA_GENERICO FFECHAINGRESOPOLIZA ', nSqlerrm);
  END;

  BEGIN

        INSERT INTO MOVSEGURO (SSEGURO,NMOVIMI,CMOTMOV,FMOVIMI,CMOVSEG,FEFECTO,FCONTAB,CIMPRES,CANUEXT,NSUPLEM,NMESVEN,NANYVEN,NCUACOA,
                    FEMISIO,CUSUMOV,CUSUEMI,CDOMPER,CMOTVEN,NEMPLEADO,COFICIN,CESTADOCOL,FANULAC,CUSUANU,CREGUL,CMOTANUL,CDERECHOSEMI)     
       -- INICIO - 16/04/2021 Ar 37659
       --VALUES ((select sseguro from seguros where npoliza = NNPOLIZA and ncertif = 0),
       VALUES(Vsseguro,
       --(select max(nmovimi)+ 1 from movseguro where sseguro = (select sseguro from seguros where npoliza = NNPOLIZA and ncertif = 0)),
       pnmovimi,
       --'997',to_date(sysdate,'DD/MM/RRRR'),'1',to_date(sysdate,'DD/MM/RRRR'),null,'0',null,
       '997',to_date(sysdate,'DD/MM/RRRR'),'1',v_fefectoex,null,'0',null,
       -- FIN - 16/04/2021 Ar 37659
       (select max(nsuplem)+ 1 from movseguro where sseguro = (select sseguro from seguros where npoliza = NNPOLIZA and ncertif = 0)),
        null,null,null,to_date(sysdate,'DD/MM/RRRR'),'AXIS',null,null,'998',null,'17000','1',null,null,null,null,null);
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION INSERT MOVSEGURO ' , nSqlerrm);
      --   RETURN 110167;
  END;
-- INICIO - 16/04/2021 Ar 37659
/*
  BEGIN
    INSERT INTO DETMOVSEGURO (SSEGURO,NMOVIMI,CMOTMOV,NRIESGO,CGARANT,TVALORA,TVALORD,CPREGUN,CPROPAGASUPL) 
         values ((select sseguro from seguros where npoliza = NNPOLIZA and ncertif = 0),
        --(select max(NMOVIMI)+ 1 from detmovseguro where sseguro = (select sseguro from seguros where npoliza = NNPOLIZA and ncertif = 0)),
        pnmovimi,
       -- FIN - 16/04/2021 Ar 37659
-- 14.0
        --'310','0','0',null,TVALORDFEX,'0',null);
        '310','0','0',null,SUBSTR(TVALORDFEX,1,1000),'0',null);
-- 14.0
    TVALORDFEX := null;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION INSERT DETMOVSEGURO ' , nSqlerrm);
      --   RETURN 110167;
  END;
*/
-- FIN - 16/04/2021 Ar 37659

--- FIN PYALLTIT  06062020
    -- INSERTA EL RECIBO DE EXTORNO POR TOMADOR EN CARATULA
    num_err := f_insrecibo(Vsseguro, vcagente, f_sysdate, ffecextini,
                                               ffecextfin, vcctiprec, NULL, NULL, NULL, NULL,
                                               NULL, nnrecibo, 'R', NULL, NULL, pnmovimi,
                                               dFCARPRO, -- f_sysdate +365, 
                                               v_tipocert);   

    IF num_err <> 0 THEN
      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.pr_procesa_cargue_pos', 1, 'ERROR F_INSRECIBO (2) NUM_ERR: ' || NUM_ERR, SQLERRM);
    END IF;
     -- INICIO - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP
     BEGIN
       INSERT INTO msv_recibos(id_cargue,proceso,recibo,estado)
       VALUES(v_idcargue, v_sproces, nnrecibo, 0);
     EXCEPTION
       WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR INSERT MSV_RECIBOS ', SQLERRM);
     END;
     -- FIN - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP
 BEGIN 
   SELECT count(NRECIBO)
     INTO NONRECIBO
     from MOVRECIBO where NRECIBO = nnrecibo;
   --
      UPDATE RECIBOS SET CESTAUX = 1 WHERE SSEGURO IN (VSSEGURO);
      IF NONRECIBO = 0 THEN

      SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(17, 'USER_BBDD')) INTO vctx FROM dual; 
      Insert into MOVRECIBO (SMOVREC,NRECIBO,CUSUARI,SMOVAGR,CESTREC,CESTANT,FMOVINI,FMOVFIN,FCONTAB,FMOVDIA,
                       CMOTMOV,CCOBBAN,CDELEGA,CTIPCOB,FEFEADM,CGESCOB,TMOTMOV) 
            values ((SELECT MAX(SMOVREC) + 1  FROM MOVRECIBO),nnrecibo,F_USER,'5231881','0','0',to_date(SYSDATE,'DD/MM/RRRR'),
                    null,to_date(SYSDATE,'DD/MM/RRRR'),to_date(SYSDATE,'DD/MM/RRRR'),null,null,'40',
                    null,to_date(SYSDATE,'DD/MM/RRRR'),null,null);
      END IF;
 EXCEPTION
   WHEN OTHERS THEN
     p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION MOVRECIBO ' , nSqlerrm);
 END;
-- INICIO - 16/04/2021 Ar 37659
TVALORDFEX := null;
-- FIN - 16/04/2021 Ar 37659

FOR E IN(SELECT NLINEA, CAMPO01 pnpoliza, UPPER(TRIM(CAMPO06)) TIPO, CAMPO07 NUMID , CAMPO13  CursoSede,CAMPO10  Fechaingresopoliza,
CAMPO11 PLAN1, CAMPO12  CodigoEst
-- INICIO - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
, count(*) over () total_filas
-- FIN - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
FROM INT_CARGA_GENERICO
WHERE PROCESO = p_id_cargue_in
AND   NCARGA  =  p_id_cargue_in
AND   TIPO_OPER = 'AS'
AND   CAMPO16 = 'EX'
ORDER BY NLINEA) LOOP
nIndicadorEX  := 1; --- INICIO PYALLTIT  06062020
PAC_POS_CARGUE.nCodigoEst  := E.CodigoEst;
PAC_POS_CARGUE.nSede := E.CursoSede;
PAC_POS_CARGUE.dFechaIngreso := E.Fechaingresopoliza;
/*
TI	Tarjeta identidad	34
CC	Cedula Ciudadania 36
RC	Registro civil	35
CE	Cedula extranjeria 33
PA	Pasaporte	40 
DE	Documento de Identificacion extranjero 	42
CD	Carne Diplomatico 	44
N A	Identificador del sistema (Sin Identificaci) 0
*/
IF E.TIPO = 'TI' THEN      nTIPO := 34;
ELSIF E.TIPO = 'CC' THEN   nTIPO := 36;
ELSIF E.TIPO = 'NIT' THEN   nTIPO := 37;
ELSIF E.TIPO = 'RC' THEN   nTIPO := 35;
ELSIF E.TIPO = 'CE' THEN   nTIPO := 33;
ELSIF E.TIPO = 'PA' THEN   nTIPO := 40;
ELSIF E.TIPO = 'DE' THEN   nTIPO := 42;
ELSIF E.TIPO = 'CD' THEN   nTIPO := 44;
ELSIF E.TIPO = 'N A' THEN  nTIPO := 0;
ELSIF E.TIPO = 'NA' THEN  nTIPO := 0;
-- INICIO - Company - 07/04/2021 - Ar 39653 - Validacion tipo documento numero unico identificacion
ELSIF E.TIPO = 'NUIP' THEN  nTIPO := 38;
-- FIN - Company - 07/04/2021 - Ar 39653 - Validacion tipo documento numero unico identificacion
END IF;
--
N := PAC_POS_CARGUE.f_baja_certif(E.pnpoliza,p_id_cargue_in,nTIPO,E.NUMID,E.NLINEA,E.PLAN1,nnrecibo);

IF N <> 0 THEN
  p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'ERROR RETORNA F_BAJA_CERTIF N: ' || N , Sqlerrm);    
END IF;

     -- INICIO - 16/04/2021 Ar 37659
     BEGIN
       SELECT sseguro
       INTO v_sseguro_cert
       FROM seguros
       WHERE npoliza = E.pnpoliza
       AND ncertif = v_ncertif;
     EXCEPTION
       WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION SELECT SEGUROS ', sqlerrm);
     END;
     BEGIN
       SELECT MAX(nmovimi)
       INTO v_nmovimi_cert
       FROM MOVSEGURO
       WHERE sseguro = v_sseguro_cert;
     EXCEPTION
       WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION SELECT MOVSEGURO ', sqlerrm);
     END;
     BEGIN
       INSERT INTO detmovsegurocol(sseguro_0, nmovimi_0, sseguro_cert, nmovimi_cert)
                           VALUES (Vsseguro, pnmovimi, v_sseguro_cert, v_nmovimi_cert );
     EXCEPTION
       WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION INSERT DETMOVSEGUROCOL INCLUSION Vsseguro: ' || Vsseguro, sqlerrm);
     END;
     -- FIN - 16/04/2021 Ar 37659

--
-- INICIO - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
--IF E.nlinea = 1 THEN

-- INICIO - 16/04/2021 Ar 37659
IF TVALORDFEX IS NULL OR E.nlinea = 1 THEN
  TVALORDFEX := v_ncertif || ' - ';
-- INICIO - 20/04/2021 - Ar 39815
--ELSE
-- FIN - 16/04/2021 Ar 37659
ELSIF E.nlinea = E.total_filas THEN
-- INICIO - 20/04/2021 - Ar 39815
TVALORDFEX := TVALORDFEX || v_ncertif;
-- INICIO - 16/04/2021 Ar 37659
END IF;

-- FIN - 16/04/2021 Ar 37659
--ELSIF E.nlinea = E.total_filas THEN
--TVALORDFEX := TVALORDFEX || v_ncertif;
--END IF;
-- FIN - 28/09/2020 - Company - AR 37416 - Incidencias Validacion Cargue Masivo
COMMIT;
END LOOP;
IF NVL(nIndicadorEX,0)  = 1 THEN --- INICIO PYALLTIT  06062020
-- INICIO - 07/01/2021 Ar 37659
BEGIN
  SELECT sseguro 
  INTO v_sseguro_dm
  FROM seguros 
  WHERE npoliza = NNPOLIZA 
  AND ncertif = 0;
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,' EXCEPCION SELECT SEGUROS NNPOLIZA: ' || NNPOLIZA, nSqlerrm);
END;
-- INICIO - 16/04/2021 Ar 37659
/*
BEGIN
  SELECT MAX(NMOVIMI)+ 1 
  INTO v_nmovimi_dm      
  FROM detmovseguro 
  WHERE sseguro = v_sseguro_dm;
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,' EXCEPCION SELECT DETMOVSEGURO NNPOLIZA: ' || NNPOLIZA, nSqlerrm);
END;
-- FIN - 07/01/2021 Ar 37659
*/
-- FIN - 16/04/2021 Ar 37659

BEGIN
  INSERT INTO DETMOVSEGURO (SSEGURO,NMOVIMI,CMOTMOV,NRIESGO,CGARANT,TVALORA,TVALORD,CPREGUN,CPROPAGASUPL) 
      -- INICIO - 16/04/2021 Ar 37659
      -- values ((select sseguro from seguros where npoliza = NNPOLIZA and ncertif = 0),
      --(select max(NMOVIMI)+ 1 from detmovseguro where sseguro = (select sseguro from seguros where npoliza = NNPOLIZA and ncertif = 0)),
      values (v_sseguro_dm,pnmovimi,
      -- FIN - 16/04/2021 Ar 37659
-- 14.0
        --'310','0','0',null,TVALORDFEX,'0',null);
        '310','0','0',null,SUBSTR(TVALORDFEX,1,1000),'0',null);
-- 14.0
      TVALORDFEX := null;
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,' EXCEPCION INSERT DETMOVSEGURO NNPOLIZA: ' || NNPOLIZA, Sqlerrm);
    --   RETURN 110167;
END;
END IF; --- INICIO PYALLTIT  06062020
--
TOTALPRIMAFEX:=0;
--
-- INICIO - 11/09/2020 - Company - AR 37166 - Incidencias HU-EMI-APGP-004 
num_err:= pac_md_produccion.f_val_primpresup(Vsseguro,vresul);
IF NVL(nIndicadorEX,0) = 1 AND NVL(vresul,0) = 1 THEN
  BEGIN
  SELECT MIN(nrecibo)
    INTO vprimrecibo
    FROM adm_recunif
   WHERE nrecunif = nnrecibo;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

FOR O IN (SELECT D.CGARANT,
SUM(D.ICONCEP)IPRIANU, d.cconcep, A.nrecunif
FROM DETRECIBOS D,adm_recunif A
WHERE D.NRECIBO = A.NRECIBO
AND A.NRECIBO = vprimrecibo
AND A.nrecunif = nnrecibo
GROUP BY D.CGARANT,d.cconcep, A.nrecunif)LOOP

    num_err := f_insdetrec(nnrecibo, 
                           O.CCONCEP,
                           O.IPRIANU,
                           NULL,
                           O.CGARANT,
                           1,
                           NULL,
                           NULL,
                           pnmovimi,
                           0,
                           Vsseguro,
                           1,
                           -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
                           /*
                           NULL,
                           NULL,
                           NULL,
                           0
                           );
                           */
                           O.IPRIANU,
                           SYSDATE,
                           NULL,
                           0
                           );
                           IF num_err <> 0 THEN
                             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 1, 'ERROR F_INSDETRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
                           END IF;
                           -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo

   IF o.cconcep = 0 OR o.cconcep = 50 THEN
     TOTALPRIMAFEX := ROUND(TOTALPRIMAFEX +  O.IPRIANU);                                  

   END IF;
COMMIT;
END LOOP;
ELSE
-- FIN - 11/09/2020 - Company - AR 37166 - Incidencias HU-EMI-APGP-004 

FOR O IN (SELECT D.CGARANT,
SUM(D.ICONCEP)IPRIANU,
d.cconcep cconcep,
A.nrecunif
FROM DETRECIBOS D,adm_recunif A
WHERE D.NRECIBO = A.NRECIBO
AND A.nrecunif = nnrecibo
group BY D.CGARANT,d.cconcep,A.nrecunif)LOOP

-- INSERTA DETALLE DE RECIBO AGRUPADOR 
--- INICIO PYALLTIT  06062020
NNRECUNIF := O.nrecunif;
IF NVL(nReciboPor,100) = 100 THEN 
--- FIN PYALLTIT  06062020

    num_err := f_insdetrec(nnrecibo, --pnrecibo,
                                    -- INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
                                    O.CCONCEP,
                                    O.IPRIANU,
                                    -- FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
                                    NULL, --xploccoa,
                                    O.CGARANT, 
                                    1,
                                    NULL, --xctipcoa,
                                    NULL, --xcageven_gar,
                                    pnmovimi, --xnmovima_gar,
                                    0, --xccomisi,
                                    Vsseguro,
                                    1,
                                    -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
                                    /*
                                    NULL,
                                    NULL,
                                    NULL,
                                    0 --decimals
                                    );
                                    */
                                    O.IPRIANU,
                                    SYSDATE,
                                    NULL,
                                    0 --decimals
                                    );
                                    IF num_err <> 0 THEN
                                      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 1, 'ERROR F_INSDETRECIBO NUM_ERR: ' || NUM_ERR, SQLERRM);
                                    END IF;
                                    -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo

   -- INICIO - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
   IF O.cconcep = 0 OR O.cconcep = 50 then
   TOTALPRIMAFEX := ROUND(TOTALPRIMAFEX +  O.IPRIANU);                                  

   -- FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
   END IF;
   -- FIN - 10/08/2020 - Company - AR 36831 - Cargue de Asegurados con recibos con comision -- 37033 AR Incidencias HU-EMI-APGP-017
COMMIT;
END IF;	   
END LOOP;
--- INICIO PYALLTIT  06062020
-- INICIO - 11/09/2020 - Company - AR 37166 - Incidencias HU-EMI-APGP-004 

END IF;
-- FIN - 11/09/2020 - Company - AR 37166 - Incidencias HU-EMI-APGP-004 
IF NVL(nIndicadorEX,0)  = 1 THEN 
BEGIN
    -- INICIO - 08/04/2021 - Company - Ar 39679 - Inconsistencia fecha efecto recibo caratula
    -- SELECT TO_DATE(MIN(CAMPO10),'DD/MM/RRRR')  Fechaingresopoliza
    SELECT MIN(TO_DATE(CAMPO10,'DD/MM/RRRR'))  Fechaingresopoliza
    -- FIN - 08/04/2021 - Company - Ar 39679 - Inconsistencia fecha efecto recibo caratula
    INTO  FFechaingresopoliza
    FROM INT_CARGA_GENERICO
    WHERE PROCESO = p_id_cargue_in
    AND   NCARGA  =  p_id_cargue_in
    AND   TIPO_OPER = 'AS'
    AND   CAMPO16 = 'EX';
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION SELECT INT_CARGA_GENERICO FFECHAINGRESOPOLIZA ', nSqlerrm);
END;

BEGIN
UPDATE RECIBOS
-- INICIO - 08/04/2021 - Company - Ar 39679 - Inconsistencia fecha efecto recibo caratula
-- SET   FEFECTO =  NVL(FFechaingresopoliza,ffecextini)
SET   FEFECTO =  FFechaingresopoliza
-- FIN - 08/04/2021 - Company - Ar 39679 - Inconsistencia fecha efecto recibo caratula
     -- INICIO - 12/11/2020 - Company - Ar 37845 Incidencias Preproduccion Revision Movimientos PW vs iAXIS
     --,FVENCIM =  FFVENCIM
     ,FVENCIM = dFCARPRO
     -- FIN - 12/11/2020 - Company - Ar 37845 Incidencias Preproduccion Revision Movimientos PW vs iAXIS
WHERE NRECIBO =  NNRECUNIF;
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION UPDATE RECIBOS FEFECTO, FVENCIM, NRECIBO ', nSqlerrm);
END;
END IF; 

--- FIN PYALLTIT  06062020

--IF nReciboPor = 100 THEN 					   
BEGIN
 Insert into VDETRECIBOS (NRECIBO,IPRINET,IRECEXT,ICONSOR,IRECCON,IIPS,IDGS,IARBITR,IFNG,IRECFRA,IDTOTEC,IDTOCOM,ICOMBRU,
       ICOMRET,IDTOOM,IPRIDEV,ITOTPRI,ITOTDTO,ITOTCON,ITOTIMP,ITOTALR,IDERREG,ITOTREC,ICOMDEV,IRETDEV,ICEDNET,ICEDREX,ICEDCON,
       ICEDRCO,ICEDIPS,ICEDDGS,ICEDARB,ICEDFNG,ICEDRFR,ICEDDTE,ICEDDCO,ICEDCBR,ICEDCRT,ICEDDOM,ICEDPDV,ICEDREG,ICEDCDV,ICEDRDV,
       IT1PRI,IT1DTO,IT1CON,IT1IMP,IT1REC,IT1TOTR,IT2PRI,IT2DTO,IT2CON,IT2IMP,IT2REC,IT2TOTR,ICOMCIA,ICOMBRUI,ICOMRETI,ICOMDEVI,
       ICOMDRTI,ICOMBRUC,ICOMRETC,ICOMDEVC,ICOMDRTC,IOCOREC,IIMP_1,IIMP_2,IIMP_3,IIMP_4,ICONVOLEODUCTO) 
       values (nnrecibo,TOTALPRIMAFEX,'0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMAFEX,TOTALPRIMAFEX,'0','0','0',TOTALPRIMAFEX,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMAFEX,'0','0','0','0',TOTALPRIMAFEX,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION INSERT VDETRECIBOS ' , nSqlerrm);
END;

BEGIN
       Insert into VDETRECIBOS_MONPOL (NRECIBO,IPRINET,IRECEXT,ICONSOR,IRECCON,IIPS,IDGS,IARBITR,IFNG,IRECFRA,IDTOTEC,IDTOCOM,
       ICOMBRU,ICOMRET,IDTOOM,IPRIDEV,ITOTPRI,ITOTDTO,ITOTCON,ITOTIMP,ITOTALR,IDERREG,ITOTREC,ICOMDEV,IRETDEV,ICEDNET,ICEDREX,
       ICEDCON,ICEDRCO,ICEDIPS,ICEDDGS,ICEDARB,ICEDFNG,ICEDRFR,ICEDDTE,ICEDDCO,ICEDCBR,ICEDCRT,ICEDDOM,ICEDPDV,ICEDREG,ICEDCDV,
       ICEDRDV,IT1PRI,IT1DTO,IT1CON,IT1IMP,IT1REC,IT1TOTR,IT2PRI,IT2DTO,IT2CON,IT2IMP,IT2REC,IT2TOTR,ICOMCIA,ICOMBRUI,ICOMRETI,
       ICOMDEVI,ICOMDRTI,ICOMBRUC,ICOMRETC,ICOMDEVC,ICOMDRTC,IOCOREC,IIMP_1,IIMP_2,IIMP_3,IIMP_4,ICONVOLEODUCTO) 
       values (nnrecibo,TOTALPRIMAFEX,'0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMAFEX,TOTALPRIMAFEX,'0','0','0',TOTALPRIMAFEX,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',TOTALPRIMAFEX,'0','0','0','0',TOTALPRIMAFEX,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION INSERT VDETRECIBOS ' , nSqlerrm);
END;
COMMIT;
--END IF;

--- INICIO PYALLTIT  14072020
IF  NVL(nReciboPor,100) = 100 AND NVL(nIndicadorEX,0)  = 1  AND NVL(nExisteRetorno,0) = 1 THEN 

num_err := f_agruparecibo_pos(NNPOLIZA, nsproduc_pos, -- r0.sproduc, 
                                          NVL(FFechaingresopoliza,ffecextini), -- r0.fefecto,
                                          f_sysdate, 
                                          17, -- r0.cempres,
                                          NULL, -- t_recibo, 
                                          9, -- v_tiprec, 
                                          1);              


COMMIT;
END IF;
--- FIN PYALLTIT  14072020			  
END IF; --- INICIO PYALLTIT  06062020
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '11787 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
--- INICIO PYALLTIT  06062020
BEGIN
  SELECT CSITUAC,nPoliza
    INTO nCSITUAC, nnPolizaSit
    FROM SEGUROS
   WHERE SSEGURO = VSSEGURO;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION SELECT NCSITUAC, NNPOLIZASIT FROM SEGUROS ' , nSqlerrm);
END;
--- FIN PYALLTIT  06062020
BEGIN
  UPDATE SEGUROS SET CSITUAC = 0 WHERE SSEGURO = VSSEGURO;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION UPDATE SEGUROS CSITUAC ', nSqlerrm);
END;
COMMIT;

--- INICIO PYALLTIT  06062020
FOR X IN(SELECT SSEGURO FROM SEGUROS WHERE NPOLIZA = nnPolizaSit AND CSITUAC = 5) LOOP
  BEGIN
    UPDATE SEGUROS SET CSITUAC = 0 WHERE SSEGURO = X.SSEGURO;
    COMMIT;
  EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION UPDATE SEGUROS CSITUAC ', nSqlerrm);
  END;
END LOOP;
--- FIN PYALLTIT  06062020

--FIN 2.0         16/04/2020  Company                AJUSTE PARA CARGA MASIVA DEL PORTAL WEB
--- INICIO PYALLTIT  06062020
BEGIN
  UPDATE MSV_TB_CARGUE_MASIVO_DET
  SET TEXTO = SUBSTR(TEXTO,LENGTH(nnPolizaSit) + 2,LENGTH(TEXTO))
  WHERE ID_CARGUE = p_id_cargue_in;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION UPDATE MSV_TB_CARGUE_MASIVO_DET SET TEXTO ' , nSqlerrm);
END;
BEGIN
  UPDATE MSV_TB_CARGUE_MASIVO_DET
    SET TEXTO = SUBSTR(TEXTO,1,LENGTH(TEXTO) - 1)
  WHERE ID_CARGUE = p_id_cargue_in
    AND  INSTR(TEXTO,';IN;') <> 0;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION UPDATE MSV_TB_CARGUE_MASIVO_DET SET TEXTO(2)' , nSqlerrm);
END;
--- FIN PYALLTIT  06062020
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '11842 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
--- INICIO PYALLTIT  06062020
IF NVL(nIndicadorEX,0)  = 1 AND NVL(nIndicadorIN,0)  = 0 THEN
FOR X IN(SELECT * FROM RECIBOS  R 
         WHERE R.SSEGURO IN(SELECT S.SSEGURO FROM SEGUROS S WHERE S.NPOLIZA = nnPolizaSit)
         AND R.NRECIBO NOT IN(SELECT D.NRECIBO FROM DETRECIBOS D)) LOOP
DELETE FROM RECIBOSREDCOM M
WHERE M.NRECIBO = X.NRECIBO;
COMMIT;
DELETE FROM MOVRECIBO M
WHERE M.NRECIBO = X.NRECIBO;
COMMIT;
DELETE FROM RECIBOS M
WHERE M.NRECIBO = X.NRECIBO;
COMMIT;
-- INICIO - 16/04/2021 Ar 37659
/*
BEGIN
 SELECT COUNT(*)
 INTO nMovi
 FROM MOVSEGURO
 WHERE sseguro = x.sseguro and nmovimi = x.nmovimi + 1;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
   nMovi := 0;
END;
IF NVL(nMovi,0) <> 0 THEN
    DELETE FROM DETMOVSEGURO where sseguro = x.sseguro and nmovimi = x.nmovimi + 1;
    COMMIT;
    BEGIN
    DELETE FROM MOVSEGURO    WHERE sseguro = x.sseguro and nmovimi = x.nmovimi + 1;
    COMMIT;
    EXCEPTION
       WHEN OTHERS THEN
       NULL;
       COMMIT;
    END;
---ELSE
  --  DELETE FROM DETMOVSEGURO where sseguro = x.sseguro and nmovimi = x.nmovimi;
  --  COMMIT;
   -- DELETE FROM MOVSEGURO    WHERE sseguro = x.sseguro and nmovimi = x.nmovimi;
  --  COMMIT;
END IF;
*/
-- FIN - 16/04/2021 Ar 37659
END LOOP;
END IF;
COMMIT;
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '11890 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
BEGIN

  UPDATE MOVSEGURO M
     -- INICIO - 07/01/2021 Ar 37659
     --SET M.FEMISIO = TRUNC(SYSDATE)
     SET M.FEMISIO = TRUNC(SYSDATE), FEFECTO = v_fefecto_carga, CUSUMOV = 'AXIS'
     -- FIN - 07/01/2021 Ar 37659
   WHERE EXISTS(SELECT 1
                  FROM SEGUROS S
                 WHERE S.NPOLIZA = NNPOLIZA
                   AND S.NCERTIF = 0
                   AND S.SSEGURO = M.SSEGURO)
                   AND M.NMOVIMI = pnmovimi
                   AND M.FEMISIO IS NULL;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION UPDATE MOVSEGURO FEMISIO ', nSqlerrm);
END;

BEGIN

  UPDATE MOVSEGURO M
     SET M.FEMISIO = TRUNC(SYSDATE)
   WHERE EXISTS(SELECT 1
                  FROM SEGUROS S
                 WHERE S.NPOLIZA = NNPOLIZA
                   AND   S.NCERTIF <> 0
             AND   S.SSEGURO = M.SSEGURO)
-- AND   M.NMOVIMI = pnmovimi
AND   M.FEMISIO IS NULL;
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION UPDATE MOVSEGURO(2) FEMISIO ', nSqlerrm);
END;

--18.0
BEGIN
  update msv_tb_cargue_masivo
     set estado_proceso = pac_msv_constantes.c_estado_cargue_terminado,fecha_modificacion = current_timestamp	   								   
   where id = p_id_cargue_in;
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',1,'EXCEPCION UPDATE MSV_TB_CARGUE_MASIVO SET ESTADO_PROCESO ' , nSqlerrm);
END;
--18.0
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '11939 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
--- FIN PYALLTIT  06062020
--Ini Company(LARO) 28112020 Factura Electronica
    FOR FE IN(
         SELECT NLINEA 
               ,CAMPO01 PNPOLIZA 
               ,UPPER(TRIM(CAMPO06)) TIPO 
               ,CAMPO07 NUMID 
               ,CAMPO19 DIRECCION
               ,CAMPO20 DPTO
               ,CAMPO21 CIUDAD
               ,CAMPO22 TELFIJO
               ,CAMPO23 TELMOVIL
               ,CAMPO14 EMAIL
               ,COUNT(*) OVER () TOTAL_FILAS
          FROM INT_CARGA_GENERICO
         WHERE PROCESO      = p_id_cargue_in
           AND NCARGA       = p_id_cargue_in
           AND TIPO_OPER    = 'AS'
           AND CAMPO16      = 'IN'
         ORDER BY NLINEA) 
    LOOP

    IF N = 0 THEN 
      BEGIN
         SELECT CRESPUE
           INTO v_pregun535
           FROM PREGUNPOLSEG 
          WHERE SSEGURO = (SELECT SSEGURO FROM SEGUROS WHERE NPOLIZA = FE.PNPOLIZA AND NCERTIF = 0)
            AND CPREGUN = 535 
            AND NMOVIMI = (SELECT MAX(NMOVIMI)
                             FROM PREGUNPOLSEG 
                            WHERE SSEGURO = (SELECT SSEGURO FROM SEGUROS WHERE NPOLIZA = FE.PNPOLIZA AND NCERTIF = 0)
                              AND CPREGUN = 535);

         --0    =   Asegurado
         --100  =   Tomador   
         IF v_pregun535 = 0 THEN  --> Por Asegurado = 0
            --Direccion
            BEGIN
            SELECT CPOBLAC, CPROVIN, TDOMICI 
              INTO V_CPOBLAC_CERO, V_CPROVIN_CERO, V_TDOMICI_CERO
              FROM PER_DIRECCIONES 
             WHERE SPERSON = (SELECT SPERSON 
                                FROM TOMADORES 
                               WHERE SSEGURO IN (SELECT SSEGURO FROM SEGUROS WHERE NPOLIZA = FE.PNPOLIZA AND NCERTIF = 0))
               AND CDOMICI = 1
               AND CTIPDIR = 1;
            EXCEPTION WHEN OTHERS THEN
                V_TDOMICI_CERO := 'NO REGISTRA DIRECCION';
            END;

            BEGIN
            SELECT TDOMICI 
              INTO V_TDOMICI
              FROM PER_DIRECCIONES 
             WHERE SPERSON = (SELECT SPERSON
                                FROM PER_PERSONAS
                               WHERE SPERSON IN (SELECT SPERSON 
                                                   FROM TOMADORES 
                                                  WHERE SSEGURO IN (SELECT SSEGURO 
                                                                      FROM SEGUROS
                                                                     WHERE NPOLIZA = FE.PNPOLIZA)
                                                 )
                                 AND NNUMIDE = FE.NUMID)
               AND CDOMICI = 1
               AND CTIPDIR = 1;
            EXCEPTION WHEN OTHERS THEN
                V_TDOMICI := ' ';
            END;

            IF V_TDOMICI = 'NO REGISTRA DIRECCION' THEN
               IF FE.DIRECCION IS NOT NULL THEN
                BEGIN
                UPDATE PER_DIRECCIONES 
                   SET TDOMICI = FE.DIRECCION
                       ,CPROVIN = NVL(FE.DPTO,CPROVIN)   --DPTO
                       ,CPOBLAC = NVL(FE.CIUDAD,CPOBLAC) --CIUDAD
                 WHERE SPERSON = (SELECT SPERSON
                                    FROM PER_PERSONAS
                                   WHERE SPERSON IN (SELECT SPERSON 
                                                       FROM TOMADORES 
                                                      WHERE SSEGURO IN (SELECT SSEGURO 
                                                                          FROM SEGUROS
                                                                         WHERE NPOLIZA = FE.PNPOLIZA)
                                                 )
                                 AND NNUMIDE = FE.NUMID)
                   AND CDOMICI = 1
                   AND CTIPDIR = 1;
                COMMIT;
                EXCEPTION
                  WHEN OTHERS THEN
                    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION UPDATE PER_DIRECCIONES FE.NUMID: ' || FE.NUMID, Sqlerrm);
                END;

               ELSE
                BEGIN
                UPDATE PER_DIRECCIONES 
                   SET TDOMICI = V_TDOMICI_CERO
                       ,CPROVIN = NVL(V_CPROVIN_CERO,CPROVIN)   --DPTO
                       ,CPOBLAC = NVL(V_CPOBLAC_CERO,CPOBLAC)   --CIUDAD
                 WHERE SPERSON = (SELECT SPERSON
                                    FROM PER_PERSONAS
                                   WHERE SPERSON IN (SELECT SPERSON 
                                                       FROM TOMADORES 
                                                      WHERE SSEGURO IN (SELECT SSEGURO 
                                                                          FROM SEGUROS
                                                                         WHERE NPOLIZA = FE.PNPOLIZA)
                                                 )
                                 AND NNUMIDE = FE.NUMID)
                   AND CDOMICI = 1
                   AND CTIPDIR = 1;
                COMMIT;
                EXCEPTION
                  WHEN OTHERS THEN
                    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION UPDATE PER_DIRECCIONES FE.NUMID: ' || FE.NUMID, Sqlerrm);
                END;

               END IF;
            ELSIF V_TDOMICI <> ' ' THEN 
                IF FE.DIRECCION IS NOT NULL THEN
                  BEGIN
                    UPDATE PER_DIRECCIONES 
                       SET TDOMICI = FE.DIRECCION
                           ,CPROVIN = NVL(FE.DPTO,CPROVIN)   --DPTO
                           ,CPOBLAC = NVL(FE.CIUDAD,CPOBLAC) --CIUDAD
                     WHERE SPERSON = (SELECT SPERSON
                                        FROM PER_PERSONAS
                                       WHERE SPERSON IN (SELECT SPERSON 
                                                           FROM TOMADORES 
                                                          WHERE SSEGURO IN (SELECT SSEGURO 
                                                                              FROM SEGUROS
                                                                             WHERE NPOLIZA = FE.PNPOLIZA)
                                                     )
                                     AND NNUMIDE = FE.NUMID)
                       AND CDOMICI = 1
                       AND CTIPDIR = 1;
                    COMMIT;
                EXCEPTION
                  WHEN OTHERS THEN
                    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION UPDATE PER_DIRECCIONES FE.NUMID: ' || FE.NUMID, Sqlerrm);
                END;

                END IF;    
            END IF;   
            --Departamento  OK
            --Ciudad        OK

            --Telefono Fijo
            BEGIN
            SELECT TVALCON
              INTO V_TVALCON_CERO
              FROM PER_CONTACTOS 
             WHERE SPERSON IN (SELECT SPERSON 
                                 FROM PER_PERSONAS 
                                WHERE SPERSON IN (SELECT SPERSON 
                                                    FROM TOMADORES 
                                                   WHERE SSEGURO IN (SELECT SSEGURO 
                                                                       FROM SEGUROS 
                                                                      WHERE NPOLIZA = FE.PNPOLIZA AND NCERTIF = 0)
                                                 )
                              )
               AND CMODCON = 3;

            BEGIN 
            SELECT SPERSON, TVALCON
              INTO V_SPERSON_CERT, V_TVALCON_CERT
              FROM PER_CONTACTOS 
             WHERE SPERSON = (SELECT SPERSON
                                FROM PER_PERSONAS
                               WHERE SPERSON IN (SELECT SPERSON 
                                                   FROM TOMADORES 
                                                  WHERE SSEGURO IN (SELECT SSEGURO 
                                                                      FROM SEGUROS
                                                                     WHERE NPOLIZA = FE.PNPOLIZA)
                                             )
                             AND NNUMIDE = FE.NUMID)
               AND CMODCON = 3;    
            EXCEPTION WHEN OTHERS THEN 
                V_SPERSON_CERT := 0;
                V_TVALCON_CERT := ' ';
            END;

            IF FE.TELFIJO IS NOT NULL THEN

                IF V_TVALCON_CERT <> ' ' THEN

                  BEGIN
                    UPDATE PER_CONTACTOS 
                       SET TVALCON = FE.TELFIJO 
                     WHERE SPERSON = (SELECT SPERSON
                                        FROM PER_PERSONAS
                                       WHERE SPERSON IN (SELECT SPERSON 
                                                           FROM TOMADORES 
                                                          WHERE SSEGURO IN (SELECT SSEGURO 
                                                                              FROM SEGUROS
                                                                             WHERE NPOLIZA = FE.PNPOLIZA)
                                                     )
                                     AND NNUMIDE = FE.NUMID)
                       AND CMODCON = 3;
                    COMMIT;
                  EXCEPTION
                    WHEN OTHERS THEN
                      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION UPDATE PER_CONTACTOS FE.NUMID: ' || FE.NUMID, Sqlerrm);
                  END;

                ELSE
                    BEGIN
                    SELECT SPERSON 
                      INTO V_SPERSON_CERT
                      FROM PER_PERSONAS 
                     WHERE NNUMIDE = FE.NUMID;
                    EXCEPTION WHEN OTHERS THEN 
                        V_SPERSON_CERT := 0;
                    END;

                    IF V_SPERSON_CERT <> 0 THEN                

                      BEGIN
                        INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
                        VALUES (V_SPERSON_CERT,'17000',3,1,NULL,FE.TELFIJO,'79962359',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
                        COMMIT;                    
                      EXCEPTION
                        WHEN OTHERS THEN
                          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS FE.NUMID: ' || FE.NUMID, Sqlerrm);
                      END;

                    END IF;
                END IF;

            ELSE

                IF V_TVALCON_CERT <> ' ' THEN

                  BEGIN
                    UPDATE PER_CONTACTOS 
                       SET TVALCON = V_TVALCON_CERO 
                     WHERE SPERSON = (SELECT SPERSON
                                        FROM PER_PERSONAS
                                       WHERE SPERSON IN (SELECT SPERSON 
                                                           FROM TOMADORES 
                                                          WHERE SSEGURO IN (SELECT SSEGURO 
                                                                              FROM SEGUROS
                                                                             WHERE NPOLIZA = FE.PNPOLIZA)
                                                     )
                                     AND NNUMIDE = FE.NUMID)
                       AND CMODCON = 3;
                    COMMIT;
                  EXCEPTION
                    WHEN OTHERS THEN
                      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION UPDATE PER_CONTACTOS FE.NUMID: ' || FE.NUMID, Sqlerrm);
                  END;

                ELSE
                    BEGIN
                    SELECT SPERSON 
                      INTO V_SPERSON_CERT
                      FROM PER_PERSONAS 
                     WHERE NNUMIDE = FE.NUMID;
                    EXCEPTION WHEN OTHERS THEN 
                        V_SPERSON_CERT := 0;
                    END;

                    IF V_SPERSON_CERT <> 0 THEN

                      BEGIN
                        INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
                        VALUES (V_SPERSON_CERT,'17000',3,1,NULL,V_TVALCON_CERO,'79962359',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
                        COMMIT;                
                      EXCEPTION
                        WHEN OTHERS THEN
                          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS FE.NUMID: ' || FE.NUMID, Sqlerrm);
                      END;

                    END IF;    

                END IF;

            END IF;

            END;

            --Telefono Movil
            BEGIN
            SELECT TVALCON
              INTO V_TVALCON_CERO
              FROM PER_CONTACTOS 
             WHERE SPERSON IN (SELECT SPERSON 
                                 FROM PER_PERSONAS 
                                WHERE SPERSON IN (SELECT SPERSON 
                                                    FROM TOMADORES 
                                                   WHERE SSEGURO IN (SELECT SSEGURO 
                                                                       FROM SEGUROS 
                                                                      WHERE NPOLIZA = FE.PNPOLIZA AND NCERTIF = 0)
                                                 )
                              )
               AND CMODCON = 4;

            BEGIN 
            SELECT SPERSON, TVALCON
              INTO V_SPERSON_CERT, V_TVALCON_CERT
              FROM PER_CONTACTOS 
             WHERE SPERSON = (SELECT SPERSON
                                FROM PER_PERSONAS
                               WHERE SPERSON IN (SELECT SPERSON 
                                                   FROM TOMADORES 
                                                  WHERE SSEGURO IN (SELECT SSEGURO 
                                                                      FROM SEGUROS
                                                                     WHERE NPOLIZA = FE.PNPOLIZA)
                                             )
                             AND NNUMIDE = FE.NUMID)
               AND CMODCON = 4;    
            EXCEPTION WHEN OTHERS THEN 
                V_SPERSON_CERT := 0;
                V_TVALCON_CERT := ' ';               
            END;

            IF FE.TELMOVIL IS NOT NULL THEN

                IF V_TVALCON_CERT <> ' ' THEN

                  BEGIN
                    UPDATE PER_CONTACTOS 
                       SET TVALCON = FE.TELMOVIL 
                     WHERE SPERSON = (SELECT SPERSON
                                        FROM PER_PERSONAS
                                       WHERE SPERSON IN (SELECT SPERSON 
                                                           FROM TOMADORES 
                                                          WHERE SSEGURO IN (SELECT SSEGURO 
                                                                              FROM SEGUROS
                                                                             WHERE NPOLIZA = FE.PNPOLIZA)
                                                     )
                                     AND NNUMIDE = FE.NUMID)
                       AND CMODCON = 4;
                    COMMIT;
                  EXCEPTION
                    WHEN OTHERS THEN
                      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION UPDATE PER_CONTACTOS FE.NUMID: ' || FE.NUMID, Sqlerrm);
                  END;

                ELSE
                    BEGIN
                    SELECT SPERSON 
                      INTO V_SPERSON_CERT
                      FROM PER_PERSONAS 
                     WHERE NNUMIDE = FE.NUMID;
                    EXCEPTION WHEN OTHERS THEN 
                        V_SPERSON_CERT := 0;
                    END;

                    IF V_SPERSON_CERT <> 0 THEN                

                      BEGIN
                        INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
                        VALUES (V_SPERSON_CERT,'17000',4,6,NULL,FE.TELMOVIL,'79962359',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
                        COMMIT;                    
                      EXCEPTION
                        WHEN OTHERS THEN
                          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS FE.NUMID: ' || FE.NUMID, Sqlerrm);
                      END;

                    END IF;

                END IF;

            ELSE

                IF V_TVALCON_CERT <> ' ' THEN

                  BEGIN
                    UPDATE PER_CONTACTOS 
                       SET TVALCON = V_TVALCON_CERO 
                     WHERE SPERSON = (SELECT SPERSON
                                        FROM PER_PERSONAS
                                       WHERE SPERSON IN (SELECT SPERSON 
                                                           FROM TOMADORES 
                                                          WHERE SSEGURO IN (SELECT SSEGURO 
                                                                              FROM SEGUROS
                                                                             WHERE NPOLIZA = FE.PNPOLIZA)
                                                     )
                                     AND NNUMIDE = FE.NUMID)
                       AND CMODCON = 4;
                    COMMIT;
                  EXCEPTION
                    WHEN OTHERS THEN
                      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION UPDATE PER_CONTACTOS FE.NUMID: ' || FE.NUMID, Sqlerrm);
                  END;

                ELSE
                    BEGIN
                    SELECT SPERSON 
                      INTO V_SPERSON_CERT
                      FROM PER_PERSONAS 
                     WHERE NNUMIDE = FE.NUMID;
                    EXCEPTION WHEN OTHERS THEN 
                        V_SPERSON_CERT := 0;
                    END;

                    IF V_SPERSON_CERT <> 0 THEN                

                     BEGIN
                       INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
                        VALUES (V_SPERSON_CERT,'17000',4,6,NULL,V_TVALCON_CERO,'79962359',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
                        COMMIT;                    
                     EXCEPTION
                        WHEN OTHERS THEN
                          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS FE.NUMID: ' || FE.NUMID, Sqlerrm);
                     END;

                    END IF;    
                END IF;

            END IF;

            END;            

            --Email
            BEGIN
            SELECT TVALCON
              INTO V_TVALCON_CERO
              FROM PER_CONTACTOS 
             WHERE SPERSON IN (SELECT SPERSON 
                                 FROM PER_PERSONAS 
                                WHERE SPERSON IN (SELECT SPERSON 
                                                    FROM TOMADORES 
                                                   WHERE SSEGURO IN (SELECT SSEGURO 
                                                                       FROM SEGUROS 
                                                                      WHERE NPOLIZA = FE.PNPOLIZA AND NCERTIF = 0)
                                                 )
                              )
               AND CMODCON = 2;

            BEGIN 
            SELECT SPERSON, TVALCON
              INTO V_SPERSON_CERT, V_TVALCON_CERT
              FROM PER_CONTACTOS 
             WHERE SPERSON = (SELECT SPERSON
                                FROM PER_PERSONAS
                               WHERE SPERSON IN (SELECT SPERSON 
                                                   FROM TOMADORES 
                                                  WHERE SSEGURO IN (SELECT SSEGURO 
                                                                      FROM SEGUROS
                                                                     WHERE NPOLIZA = FE.PNPOLIZA)
                                             )
                             AND NNUMIDE = FE.NUMID)
               AND CMODCON = 2;   
            EXCEPTION WHEN OTHERS THEN 
                V_SPERSON_CERT := 0;
                V_TVALCON_CERT := ' ';               
            END;

            IF FE.EMAIL IS NOT NULL THEN

                IF V_TVALCON_CERT <> ' ' THEN

                  BEGIN
                    UPDATE PER_CONTACTOS 
                       SET TVALCON = FE.EMAIL 
                     WHERE SPERSON = (SELECT SPERSON
                                        FROM PER_PERSONAS
                                       WHERE SPERSON IN (SELECT SPERSON 
                                                           FROM TOMADORES 
                                                          WHERE SSEGURO IN (SELECT SSEGURO 
                                                                              FROM SEGUROS
                                                                             WHERE NPOLIZA = FE.PNPOLIZA)
                                                     )
                                     AND NNUMIDE = FE.NUMID)
                       AND CMODCON = 2;
                    COMMIT;
                  EXCEPTION
                    WHEN OTHERS THEN
                      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION UPDATE PER_CONTACTOS FE.NUMID: ' || FE.NUMID, Sqlerrm);
                  END;
                ELSE
                    BEGIN
                    SELECT SPERSON 
                      INTO V_SPERSON_CERT
                      FROM PER_PERSONAS 
                     WHERE NNUMIDE = FE.NUMID;
                    EXCEPTION WHEN OTHERS THEN 
                        V_SPERSON_CERT := 0;
                    END;

                    IF V_SPERSON_CERT <> 0 THEN                

                      BEGIN
                        INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
                        VALUES (V_SPERSON_CERT,'17000',2,3,NULL,FE.EMAIL,'79962359',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
                        COMMIT;                    
                      EXCEPTION
                        WHEN OTHERS THEN
                          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS V_SPERSON_CERT: ' || V_SPERSON_CERT, Sqlerrm);
                      END;
                    END IF;    
                END IF;

            ELSE

                IF V_TVALCON_CERT <> ' ' THEN

                  BEGIN
                    UPDATE PER_CONTACTOS 
                       SET TVALCON = V_TVALCON_CERO 
                     WHERE SPERSON = (SELECT SPERSON
                                        FROM PER_PERSONAS
                                       WHERE SPERSON IN (SELECT SPERSON 
                                                           FROM TOMADORES 
                                                          WHERE SSEGURO IN (SELECT SSEGURO 
                                                                              FROM SEGUROS
                                                                             WHERE NPOLIZA = FE.PNPOLIZA)
                                                     )
                                     AND NNUMIDE = FE.NUMID)
                       AND CMODCON = 2;
                    COMMIT;
                  EXCEPTION
                    WHEN OTHERS THEN
                      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION UPDATE PER_CONTACTOS FE.NUMID: ' || FE.NUMID, Sqlerrm);
                  END;
                ELSE
                    BEGIN
                    SELECT SPERSON 
                      INTO V_SPERSON_CERT
                      FROM PER_PERSONAS 
                     WHERE NNUMIDE = FE.NUMID;
                    EXCEPTION WHEN OTHERS THEN 
                        V_SPERSON_CERT := 0;
                    END;

                    IF V_SPERSON_CERT <> 0 THEN                

                      BEGIN
                        INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
                        VALUES (V_SPERSON_CERT,'17000',2,3,NULL,V_TVALCON_CERO,'79962359',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
                        COMMIT;                    
                      EXCEPTION
                        WHEN OTHERS THEN
                          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS FE.NUMID: ' || FE.NUMID, Sqlerrm);
                      END;

                    END IF;    
                END IF;

            END IF;

            END;            

         ELSE --> Por Tomador = 100
             --Direccion
             -- INICIO - 24/03/2021 - Company - Ar 37175
             /*
             IF FE.DIRECCION IS NOT NULL THEN
                  BEGIN
                    UPDATE PER_DIRECCIONES 
                       SET TDOMICI = FE.DIRECCION
                           ,CPROVIN = NVL(FE.DPTO,CPROVIN)   --DPTO
                           ,CPOBLAC = NVL(FE.CIUDAD,CPOBLAC) --CIUDAD                    
                     WHERE SPERSON = (SELECT SPERSON
                                        FROM PER_PERSONAS
                                       WHERE SPERSON IN (SELECT SPERSON 
                                                           FROM TOMADORES 
                                                          WHERE SSEGURO IN (SELECT SSEGURO 
                                                                              FROM SEGUROS
                                                                             WHERE NPOLIZA = FE.PNPOLIZA)
                                                     )
                                     AND NNUMIDE = FE.NUMID)
                       AND CDOMICI = 1
                       AND CTIPDIR = 1;
                    COMMIT;
                  EXCEPTION
                    WHEN OTHERS THEN
                      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION UPDATE PER_DIRECCIONES FE.NUMID: ' || FE.NUMID, Sqlerrm);
                  END;
             END IF;   
             */
             -- FIN - 24/03/2021 - Company - Ar 37175
            --Telefono Fijo
            BEGIN 
            SELECT SPERSON, TVALCON
              INTO V_SPERSON_CERT, V_TVALCON_CERT
              FROM PER_CONTACTOS 
             WHERE SPERSON = (SELECT SPERSON
                                FROM PER_PERSONAS
                               WHERE SPERSON IN (SELECT SPERSON 
                                                   FROM TOMADORES 
                                                  WHERE SSEGURO IN (SELECT SSEGURO 
                                                                      FROM SEGUROS
                                                                     WHERE NPOLIZA = FE.PNPOLIZA)
                                             )
                             AND NNUMIDE = FE.NUMID)
               -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
               --AND CMODCON = 3; 
               AND CTIPCON = 1;
               -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
            EXCEPTION WHEN OTHERS THEN 
                V_SPERSON_CERT := 0;
                V_TVALCON_CERT := ' ';                     
            END;

            -- INICIO - 24/03/2021 - Company - Ar 37175
            /*
            IF FE.TELFIJO IS NOT NULL THEN

                IF V_TVALCON_CERT <> ' ' THEN

                  BEGIN
                    UPDATE PER_CONTACTOS 
                       SET TVALCON = FE.TELFIJO 
                     WHERE SPERSON = (SELECT SPERSON
                                        FROM PER_PERSONAS
                                       WHERE SPERSON IN (SELECT SPERSON 
                                                           FROM TOMADORES 
                                                          WHERE SSEGURO IN (SELECT SSEGURO 
                                                                              FROM SEGUROS
                                                                             WHERE NPOLIZA = FE.PNPOLIZA)
                                                     )
                                     AND NNUMIDE = FE.NUMID)
                       -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
                       --AND CMODCON = 3;
                       AND CTIPCON = 1;
                       -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
                    COMMIT;                       
                  EXCEPTION
                    WHEN OTHERS THEN
                      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION UPDATE PER_CONTACTOS FE.NUMID: ' || FE.NUMID, Sqlerrm);
                  END;
                ELSE
                    BEGIN
                    SELECT SPERSON 
                      INTO V_SPERSON_CERT
                      FROM PER_PERSONAS 
                     WHERE NNUMIDE = FE.NUMID;
                    EXCEPTION WHEN OTHERS THEN 
                        V_SPERSON_CERT := 0;
                    END;

                    -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
                    BEGIN
                      SELECT MAX(cmodcon) + 1
                        INTO v_cmodcon
                        FROM per_contactos
                       WHERE sperson = V_SPERSON_CERT;
                    EXCEPTION
                      WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT MAX CMODCON FROM PER_CONTACTOS ' , SQLERRM);
                    END;
                    IF v_cmodcon IS NULL THEN
                      v_cmodcon := 1;
                    END IF;
                    -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021

                    IF V_SPERSON_CERT <> 0 THEN                

                      BEGIN
                        INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
                        -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
                        --VALUES (V_SPERSON_CERT,'17000',3,1,NULL,FE.TELFIJO,'79962359',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
                        VALUES (V_SPERSON_CERT,'17000',v_cmodcon,1,NULL,FE.TELFIJO,'79962359',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
                        -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
                        COMMIT;                    
                      EXCEPTION
                        WHEN OTHERS THEN
                          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT PER_CONTACTOS ' , SQLERRM);
                      END;
                    END IF;    
                END IF;
            END IF;  
            */
            -- FIN - 24/03/2021 - Company - Ar 37175

            --Telefono Movil
            BEGIN 
            SELECT SPERSON, TVALCON
              INTO V_SPERSON_CERT, V_TVALCON_CERT
              FROM PER_CONTACTOS 
             WHERE SPERSON = (SELECT SPERSON
                                FROM PER_PERSONAS
                               WHERE SPERSON IN (SELECT SPERSON 
                                                   FROM TOMADORES 
                                                  WHERE SSEGURO IN (SELECT SSEGURO 
                                                                      FROM SEGUROS
                                                                     WHERE NPOLIZA = FE.PNPOLIZA)
                                             )
                             AND NNUMIDE = FE.NUMID)
               -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
               --AND CMODCON = 4;
               AND CTIPCON = 6;    
               -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
            EXCEPTION WHEN OTHERS THEN 
                V_SPERSON_CERT := 0;
                V_TVALCON_CERT := ' ';                     
            END;
            -- INICIO - 24/03/2021 - Company - Ar 37175
            /*

            IF FE.TELMOVIL IS NOT NULL THEN
                IF V_TVALCON_CERT <> ' ' THEN

                  BEGIN
                    UPDATE PER_CONTACTOS 
                       SET TVALCON = FE.TELMOVIL 
                     WHERE SPERSON = (SELECT SPERSON
                                        FROM PER_PERSONAS
                                       WHERE SPERSON IN (SELECT SPERSON 
                                                           FROM TOMADORES 
                                                          WHERE SSEGURO IN (SELECT SSEGURO 
                                                                              FROM SEGUROS
                                                                             WHERE NPOLIZA = FE.PNPOLIZA)
                                                     )
                                     AND NNUMIDE = FE.NUMID)
                       -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
                       --AND CMODCON = 4;
                       AND CTIPCON = 6;
                       -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
                    COMMIT;
                  EXCEPTION
                    WHEN OTHERS THEN
                      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION UPDATE PER_CONTACTOS FE.NUMID: ' || FE.NUMID, Sqlerrm);
                  END;

                ELSE
                    BEGIN
                    SELECT SPERSON 
                      INTO V_SPERSON_CERT
                      FROM PER_PERSONAS 
                     WHERE NNUMIDE = FE.NUMID;
                    EXCEPTION WHEN OTHERS THEN 
                        V_SPERSON_CERT := 0;
                    END;

                    -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
                    BEGIN
                      SELECT MAX(cmodcon) + 1
                        INTO v_cmodcon
                        FROM per_contactos
                       WHERE sperson = V_SPERSON_CERT;
                    EXCEPTION
                      WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT MAX CMODCON FROM PER_CONTACTOS ' , SQLERRM);
                    END;
                    IF v_cmodcon IS NULL THEN
                      v_cmodcon := 1;
                    END IF;
                    -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
                    IF V_SPERSON_CERT <> 0 THEN                
                      BEGIN
                        INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
                        -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
                        --VALUES (V_SPERSON_CERT,'17000',4,6,NULL,FE.TELMOVIL,'79962359',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
                        VALUES (V_SPERSON_CERT,'17000',v_cmodcon,6,NULL,FE.TELMOVIL,'79962359',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
                        -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
                        COMMIT;                   
                      EXCEPTION
                        WHEN OTHERS THEN
                          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS FE.NUMID: ' || FE.NUMID, Sqlerrm);
                      END;

                    END IF;    

                END IF;
            END IF; 
            */
            -- FIN - 24/03/2021 - Company - Ar 37175
            --Email
            BEGIN 
            SELECT SPERSON, TVALCON
              INTO V_SPERSON_CERT, V_TVALCON_CERT
              FROM PER_CONTACTOS 
             WHERE SPERSON = (SELECT SPERSON
                                FROM PER_PERSONAS
                               WHERE SPERSON IN (SELECT SPERSON 
                                                   FROM TOMADORES 
                                                  WHERE SSEGURO IN (SELECT SSEGURO 
                                                                      FROM SEGUROS
                                                                     WHERE NPOLIZA = FE.PNPOLIZA)
                                             )
                             AND NNUMIDE = FE.NUMID)
               -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
               AND CTIPCON = 3;   
               -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
            EXCEPTION WHEN OTHERS THEN 
                V_SPERSON_CERT := 0;
                V_TVALCON_CERT := ' ';                     
            END;

            -- INICIO - 24/03/2021 - Company - Ar 37175
            /*
            IF FE.EMAIL IS NOT NULL THEN
                IF V_TVALCON_CERT <> ' ' THEN

                  BEGIN
                    UPDATE PER_CONTACTOS 
                       SET TVALCON = FE.EMAIL 
                     WHERE SPERSON = (SELECT SPERSON
                                        FROM PER_PERSONAS
                                       WHERE SPERSON IN (SELECT SPERSON 
                                                           FROM TOMADORES 
                                                          WHERE SSEGURO IN (SELECT SSEGURO 
                                                                              FROM SEGUROS
                                                                             WHERE NPOLIZA = FE.PNPOLIZA)
                                                     )
                                     AND NNUMIDE = FE.NUMID)
                       -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
                       AND CTIPCON = 3;
                       -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
                    COMMIT;
                  EXCEPTION
                    WHEN OTHERS THEN
                      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION UPDATE PER_CONTACTOS FE.NUMID: ' || FE.NUMID, Sqlerrm);
                  END;

                ELSE
                    BEGIN
                    SELECT SPERSON 
                      INTO V_SPERSON_CERT
                      FROM PER_PERSONAS 
                     WHERE NNUMIDE = FE.NUMID;
                    EXCEPTION WHEN OTHERS THEN 
                        V_SPERSON_CERT := 0;
                    END;

                    -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
                    BEGIN
                      SELECT MAX(cmodcon) + 1
                        INTO v_cmodcon
                        FROM per_contactos
                       WHERE sperson = V_SPERSON_CERT;
                    EXCEPTION
                      WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT MAX CMODCON FROM PER_CONTACTOS ' , SQLERRM);
                    END;
                    IF v_cmodcon IS NULL THEN
                      v_cmodcon := 1;
                    END IF;
                    -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021

                    IF V_SPERSON_CERT <> 0 THEN                
                      BEGIN
                        INSERT INTO PER_CONTACTOS (SPERSON,CAGENTE,CMODCON,CTIPCON,TCOMCON,TVALCON,CUSUARI,FMOVIMI,COBLIGA,CDOMICI,CPREFIX) 
                        -- INICIO - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021
                        --VALUES (V_SPERSON_CERT,'17000',2,3,NULL,FE.EMAIL,'79962359',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
                        VALUES (V_SPERSON_CERT,'17000',v_cmodcon,3,NULL,FE.EMAIL,'79962359',TO_DATE(F_SYSDATE, 'DD/MM/RR'),0,1,NULL);  
                        -- FIN - 02/02/2021 - Company - ID CP 205 Cargue Masivo 27-01-2021                        
                        COMMIT; 
                      EXCEPTION
                        WHEN OTHERS THEN
                          p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE',1,' EXCEPCION INSERT PER_CONTACTOS FE.NUMID: ' || FE.NUMID, Sqlerrm);
                      END;

                    END IF;

                END IF;
            END IF; 
            */
            -- FIN - 24/03/2021 - Company - Ar 37175
         END IF;
      END;
    END IF;

    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS',111,
                                   ' NUMID '    || FE.NUMID || 
                                   ' PNPOLIZA ' || FE.pnpoliza ||
                                   ' V_TDOMICI '|| V_TDOMICI, Sqlerrm);       

    END LOOP;  
--Fin Company(LARO) 28112020 Factura Electronica
p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.PR_PROCESA_CARGUE_POS', 111, '12804 INICIA PR_PROCESA_CARGUE_POS SYSTIMESTAMP: ' || SYSTIMESTAMP, nSqlerrm);
END PR_PROCESA_CARGUE_POS;

PROCEDURE P_ACTUALIZA_MSV_TB_CARGUE_MASIVO_DET(P_vr_id_cargue IN NUMBER,P_vr_nro_linea IN NUMBER,P_vr_estado IN VARCHAR2,P_vr_observaciones IN VARCHAR2) IS
    BEGIN
--INICIO 14.0  
    UPDATE MSV_TB_CARGUE_MASIVO_DET SET ESTADO = P_vr_estado, OBSERVACIONES = P_vr_observaciones, fecha_modificacion = current_timestamp
        WHERE ID_CARGUE = P_vr_id_cargue AND NRO_LINEA = P_vr_nro_linea;
--FIN 14.0
        COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.P_ACTUALIZA_MSV_TB_CARGUE_MASIVO_DET',111,' EXCEPTION UPDATE MSV_TB_CARGUE_MASIVO_DET ', Sqlerrm);
    END;

-- FIN PYALLTIT

--- INICIO PYALLTIT  14/07/2020

   FUNCTION f_generar_retorno_pos(
      pnpoliza IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnrecibo IN NUMBER,
      psproces IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R',
      ptipo IN VARCHAR2 DEFAULT 'NO')
      RETURN NUMBER IS
      vpas           NUMBER := 1;
      vobj           VARCHAR2(500) := 'PAC_POS_CARGUE.f_generar_retorno_pos';
      vpar           VARCHAR2(500)
         := 's=' || psseguro || ' n=' || pnmovimi || ' r=' || pnrecibo || ' p=' || psproces
            || ' m=' || pmodo;
      v_age          seguros.cagente%TYPE;
      v_pro          seguros.sproduc%TYPE;
      d_ini          DATE;
      d_fin          DATE;
      v_pol          seguros.npoliza%TYPE;
      v_numerr       NUMBER;
      v_idenew       rtn_mntconvenio.idconvenio%TYPE;
      v_cdomper      movseguro.cdomper%TYPE;
      v_ctiprec      recibos.ctiprec%TYPE;
      v_rec          recibos.nrecibo%TYPE;
      e_error_proc   EXCEPTION;
      xcestaux       NUMBER;
      xccobban       NUMBER;
      xcestimp       NUMBER;
      xcdelega       NUMBER;
      xcestsop       NUMBER;   -- generacion de soportes
      xcmanual       NUMBER(1);
      xnbancar       seguros.cbancar%TYPE;
      xnbancarf      seguros.cbancar%TYPE;
      xtbancar       seguros.cbancar%TYPE;
      dummy          NUMBER;
      xsmovrec       NUMBER;
      xnliqmen       NUMBER;
      xfmovim        DATE;
      v_ctipban      per_ccc.ctipban%TYPE;
      v_cbancar      per_ccc.cbancar%TYPE;
      xiprianu2      detrecibos.iconcep%TYPE;
      xploccoa       NUMBER;
      v_decimals     NUMBER := 0;
      xcmovimi       NUMBER;
      v_total        vdetrecibos.itotalr%TYPE;
      v_cuseraut     psucontrolseg.cusuaur%TYPE;
      xesccero       NUMBER(1);
      vsum85         NUMBER;
      vncertif       NUMBER;   --bug 29324/161385 - 16/12/2013 - AMC
      v_copago       pregunpolseg.crespue%TYPE;   -- BUG 27417 - MMS - 20140208
      vcuenta        NUMBER;   -- 29991/65385 - 05/02/2014

      CURSOR c_retrn(pc_sseguro IN NUMBER, pc_nmovimi IN NUMBER) IS
         SELECT c.sperson, c.nmovimi, c.pretorno
           FROM rtn_convenio c,seguros s
          WHERE c.sseguro = s.sseguro
          AND   s.npoliza = pnpoliza
          AND   s.ncertif = 0
            AND(c.nmovimi = pc_nmovimi
                OR(pc_nmovimi IS NULL
                   AND c.nmovimi = (SELECT MAX(m.nmovimi)
                                      FROM rtn_convenio m
                                     WHERE m.sseguro = S.sseguro)));

      CURSOR cur_recibos(pc_sseguro IN NUMBER, pc_nmovimi IN NUMBER, pc_nrecibo IN NUMBER) IS
         SELECT   r.*, s.sproduc produc, s.cagente AGENT, s.ctipreb tipreb, s.fcaranu caranu,
                  s.cagrpro agrpro, s.ncertif
             FROM recibos r, seguros s
            WHERE s.sseguro = pc_sseguro
              AND r.sseguro = s.sseguro
              AND(r.nmovimi = pc_nmovimi
                  OR pc_nmovimi IS NULL
                  OR pc_nrecibo IS NOT NULL)
              AND(r.nrecibo = pc_nrecibo
                  OR pc_nrecibo IS NULL)
              AND EXISTS(SELECT 1
                           FROM movrecibo m
                          WHERE m.nrecibo = r.nrecibo
                            AND m.cestrec = 0
                            AND m.fmovfin IS NULL)
              AND((NVL(r.cestaux, 0) IN(0, 2)   --BUG25357:DCT:07/01/2013:INICIO
                   AND r.ctipcoa <> 8)
                  OR(r.cestaux = 1
                     AND r.ctipcoa = 8))   --BUG25357:DCT:07/01/2013:FIN
              AND r.ctiprec NOT IN(13, 15)   -- BUG24271:DRA:16/11/2012
              AND NOT EXISTS(SELECT 1
                               FROM rtn_recretorno rtr
                              WHERE rtr.nrecibo = r.nrecibo)
         ORDER BY r.nrecibo;

      -- BUG 0025691 - 08/03/2013 - JMF: afegir 50,51
      CURSOR cur_detrecibos(pc_nrecibo IN NUMBER) IS
         SELECT   nriesgo, cgarant, cageven, nmovima, SUM(iconcep) iconcep
             FROM detrecibos
            WHERE nrecibo = pc_nrecibo
              AND cconcep IN(0, 8, 50, 58)   --Bug 27994 MCA incluir concepto de recargo fraccionamiento
         -- JLV Bug 31982, el retorno solo ha de tener en cuenta la prima y el recargo de fraccionamiento
         GROUP BY nriesgo, cgarant, cageven, nmovima;
   BEGIN
      vpas := 1000;
      IF pmodo = 'R' THEN
         IF psseguro IS NOT NULL THEN
            vpas := 1010;

            --bug 29324/161385 - 16/12/2013 - AMC
            SELECT cagente, sproduc, fefecto, npoliza, fcaranu, ncertif
              INTO v_age, v_pro, d_ini, v_pol, d_fin, vncertif
              FROM seguros
             WHERE sseguro = psseguro;

            vpas := 1020;

            IF vncertif = 0 THEN
               SELECT COUNT(1)
                 INTO v_numerr
                 FROM rtn_mntageconvenio a, rtn_mntprodconvenio b, rtn_mntconvenio c
                WHERE b.idconvenio = a.idconvenio
                  AND c.idconvenio = b.idconvenio
                  AND a.cagente = v_age
                  AND b.sproduc = v_pro
                  AND d_ini BETWEEN c.finivig AND c.ffinvig
                  -- BUG 0025691/0138159 - FAL - 20/02/2013
                  -- BUG 0025691 - 08/03/2013 - JMF: AND c.direcpol = 0
                  AND(c.direcpol = 0
                      OR(c.direcpol = 1
                         AND c.ccodconv = 'POL-' || v_pol));   --bug 29324/161385 - 16/12/2013 - AMC

               -- FI BUG 0025691/0138159
               IF v_numerr = 0 THEN
                  -- No existe el convenio, lo creamos.

                  -- buscar usuario que autoriza.
                  vpas := 1030;

                  SELECT MAX(cusuaur)
                    INTO v_cuseraut
                    FROM psucontrolseg a
                   WHERE sseguro = psseguro
                     AND ccontrol = 526051
                     AND nmovimi = (SELECT MAX(b.nmovimi)
                                      FROM psucontrolseg b
                                     WHERE b.sseguro = a.sseguro
                                       AND b.ccontrol = a.ccontrol);

                  vpas := 1040;
                  -- BUG 0025815 - 22/01/2013 - JMF: afegir sperson
                  v_numerr :=
                     pac_retorno.f_set_datconvenio
                                               (NULL, 'POL-' || v_pol,

                                                --'Directo desde poliza', d_ini, d_fin,
                                                f_axis_literales(9905021, f_usu_idioma), d_ini,
                                                d_fin,   -- BUG 0025691/0138159 - FAL - 20/02/2013
                                                --v_cuseraut, NULL, v_idenew);
                                                v_cuseraut, NULL, v_idenew, 1);   -- BUG 0025691/0138159 - FAL - 20/02/2013

                  IF NVL(v_numerr, 0) <> 0 THEN
                     RAISE e_error_proc;
                  END IF;

                  vpas := 1050;
                  v_numerr := pac_retorno.f_set_prodconvenio(v_idenew, v_pro);

                  IF NVL(v_numerr, 0) <> 0 THEN
                     RAISE e_error_proc;
                  END IF;

                  vpas := 1060;
                  v_numerr := pac_retorno.f_set_ageconvenio(v_idenew, v_age);

                  IF NVL(v_numerr, 0) <> 0 THEN
                     RAISE e_error_proc;
                  END IF;

                  vpas := 1070;

                  FOR f1 IN c_retrn(psseguro, NULL) LOOP
                     vpas := 1080;
                     -- BUG 0025580 - 08/01/2013 - JMF  : afegir ctomador

                     -- INICIO 23/01/2021 Company DESEMPLEO													
                     v_numerr := pac_retorno.f_set_benefconvenio(v_idenew, f1.sperson,
                     -- INICIO - 24/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
                                                                 --f1.pretorno);
                                                                 f1.pretorno,null);
                     -- FIN - 24/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
                     -- FIN 23/01/2021 Company DESEMPLEO

                     IF NVL(v_numerr, 0) <> 0 THEN
                        RAISE e_error_proc;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         --Fi bug 29324/161385 - 16/12/2013 - AMC
         END IF;
      END IF;

      v_numerr := 0;
      vpas := 1100;
      FOR r_rec IN cur_recibos(psseguro, pnmovimi, pnrecibo) LOOP
         vpas := 1110;

-- 29991/65385 - 05/02/2014 - INI
         SELECT COUNT(0)
           INTO vcuenta
           FROM detrecibos
          WHERE nrecibo =
                   r_rec.nrecibo   --BUG 0029991/166347 - 17/02/2014 - RCL - Canvi pnrecibo per r_rec.NRECIBO
            AND cconcep IN(0, 4, 8, 50, 54, 58, 86);

         IF vcuenta > 0 THEN
-- 29991/65385 - 05/02/2014 - FIN
            SELECT MAX(cdomper)
              INTO v_cdomper
              FROM movseguro
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi;

            IF r_rec.ctiprec = 9 THEN
               v_ctiprec := 15;   -- Recobro del Retorno
            ELSE
               v_ctiprec := 13;
            END IF;

            xsmovrec := 0;
            vpas := 1120;

            FOR r_rtn IN c_retrn(psseguro, NULL) LOOP
               vpas := 1130;
               v_rec := pac_adm.f_get_seq_cont(r_rec.cempres);
               -- <BUSCAR LOS DATOS BANCARIOS POR DEFECTO DEL BENEFICIARIO>
               vpas := 1140;
               SELECT MAX(ctipban), MAX(cbancar)
                 INTO v_ctipban, v_cbancar
                 FROM per_ccc a
                WHERE sperson = r_rtn.sperson
                  AND cnordban = (SELECT MAX(b.cnordban)
                                    FROM per_ccc b
                                   WHERE b.sperson = r_rtn.sperson
                                     AND b.cdefecto = 1);

               IF v_cbancar IS NULL THEN
                  vpas := 1150;

                  SELECT MAX(ctipban), MAX(cbancar)
                    INTO v_ctipban, v_cbancar
                    FROM per_ccc a
                   WHERE sperson = r_rtn.sperson
                     AND cnordban = (SELECT MAX(b.cnordban)
                                       FROM per_ccc b
                                      WHERE b.sperson = r_rtn.sperson);
               END IF;

               xcestaux := 0;

               -- INI RLLF 18/01/2016 0038732: POS ADM Recaudo y Cartera Ramo Salud

               /*IF NVL(f_parproductos_v(v_pro, 'ADMITE_CERTIFICADOS'), 0) = 1
                  AND NVL(f_parproductos_v(v_pro, 'RECUNIF'), 0) IN(1, 3) THEN
                  -- BUG26111:DRA:18/02/2013: Si es reunifica ha de quedar amb CESTAUX=2
                  --AND pac_seguros.f_es_col_admin(psseguro) = 1
                  --AND pac_seguros.f_get_escertifcero(NULL, psseguro) = 0 THEN
                  -- BUG26111:DRA:18/02/2013:Fi
                  xcestaux := 2;
               END IF;*/
              xcestaux := r_rec.cestaux;
               -- FIN RLLF 18/01/2016 0038732: POS ADM Recaudo y Cartera Ramo Salud

               IF pmodo = 'R' THEN
                  IF v_cbancar IS NOT NULL THEN
                     vpas := 1160;
                     xnbancar := v_cbancar;
                     v_numerr := f_ccc(xnbancar, v_ctipban, dummy, xnbancarf);
                     vpas := 1170;

                     IF v_numerr = 0
                        OR(v_numerr = 102493
                           AND f_parinstalacion_n('DIGICTRL00') = 1) THEN
                        xtbancar := v_cbancar;
                     ELSE
                        RETURN v_numerr;
                     END IF;
                  END IF;

                  IF NVL(ptipo, 'NO') = 'CERTIF0' THEN
                     xesccero := 1;
                  ELSE
                     xesccero := 0;

                     -- Inicio BUG 27417 - MMS - 20140208
                     IF r_rec.tipreb = 4 THEN
                        BEGIN
                           SELECT p1.crespue
                             INTO v_copago
                             FROM pregunpolseg p1
                            WHERE p1.sseguro = psseguro
                              AND p1.cpregun = 535
                              AND p1.nmovimi = (SELECT MAX(p2.nmovimi)
                                                  FROM pregunpolseg p2
                                                 WHERE p2.sseguro = p1.sseguro
                                                   AND p2.cpregun = p1.cpregun);
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              v_copago := NULL;
                        END;

                        IF NVL(v_copago, 100) <> 0 THEN
                           xesccero := 1;
                        END IF;
                     END IF;
                  -- Fin BUG 27417 - MMS - 20140208
                  END IF;

                  BEGIN
                     vpas := 1180;
                     -- INSERTA EL RECIBO DE RETORNO EN CERTIFICADO POR ASEGURADO
                     INSERT INTO recibos
                                 (nrecibo, sseguro, cagente, femisio,
                                  fefecto, fvencim, ctiprec, cestaux,
                                  nanuali, nfracci, ccobban, cestimp,
                                  cempres, cdelega, nriesgo, cforpag,
                                  cbancar, nmovimi, ncuacoa, ctipcoa,
                                  cestsop, nperven, cgescob, ctipban,
                                  cmanual, esccero, ctipcob, ncuotar,
                                  sperson)
                          VALUES (v_rec, psseguro, r_rec.cagente, r_rec.femisio,
                                  r_rec.fefecto, r_rec.fvencim, v_ctiprec, xcestaux,
                                  r_rec.nanuali, r_rec.nfracci, r_rec.ccobban, r_rec.cestimp,
                                  r_rec.cempres, r_rec.cdelega, r_rec.nriesgo, r_rec.cforpag,
                                  xtbancar, r_rec.nmovimi, r_rec.ncuacoa, r_rec.ctipcoa,
                                  r_rec.cestsop, r_rec.nperven, r_rec.cgescob, r_rec.ctipban,
                                  r_rec.cmanual, xesccero, r_rec.ctipcob, r_rec.ncuotar,
                                  r_rtn.sperson);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                      p_tab_error(f_sysdate, f_user, 'f_generar_retorno_pos102307', vpas,
                     'psseguro ' || psseguro ||
                              'pnpoliza' || pnpoliza||' r_rec.nrecibo: '||r_rec.nrecibo
                             ||' vcuenta: '||vcuenta||' ncertif: '||r_rec.ncertif||' v_ctiprec: '||v_ctiprec||' v_rec: '||v_rec,
                     SQLERRM);
                        RETURN 102307;   -- Registre duplicat a RECIBOS
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                    SQLCODE || ' - ' || SQLERRM);
                        RETURN 103847;   -- Error a l' inserir a RECIBOS
                  END;
                  -- INICIO - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP
                  BEGIN
                    INSERT INTO msv_recibos(id_cargue,proceso,recibo,estado)
                    VALUES(v_idcargue, v_sproces, v_rec, 0);
                  EXCEPTION
                  WHEN OTHERS THEN
                    p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR INSERT MSV_RECIBOS ', SQLERRM);
                  END;
                  -- FIN - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP
                  --BUG 24187 - 22/10/2012 - JRB - Se inserta la relacion del recibo con el retorno en la tabla rtn_recretorno
                  BEGIN
                     vpas := 1181;

                     INSERT INTO rtn_recretorno
                                 (nrecibo, nrecretorno)
                          VALUES (r_rec.nrecibo, v_rec);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        RETURN 9904388;   -- Registre duplicat a RECIBOS
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                    SQLCODE || ' - ' || SQLERRM);
                        RETURN 9904389;   -- Error a l' inserir a RECIBOS
                  END;

                  vpas := 1190;

                  IF f_sysdate < r_rec.fefecto THEN
                     xfmovim := r_rec.fefecto;
                  ELSE
                     xfmovim := f_sysdate;
                  END IF;

                  IF r_rec.agrpro = 2 THEN
                     xcmovimi := 2;   -- indica aportacion periodica
                  ELSE
                     xcmovimi := NULL;
                  END IF;

                  SELECT fmovini
                    INTO xfmovim
                    FROM movrecibo
                   WHERE nrecibo = r_rec.nrecibo
                     AND fmovfin IS NULL;

                  vpas := 1200;
                  v_numerr := f_movrecibo(v_rec, 0, NULL, xcmovimi, xsmovrec, xnliqmen, dummy,
                                          xfmovim, r_rec.ccobban, r_rec.cdelega, NULL, NULL);

                  IF NVL(v_numerr, 0) <> 0 THEN
                     RAISE e_error_proc;
                  END IF;
               ELSE
                  vpas := 1210;

                  INSERT INTO reciboscar
                              (sproces, nrecibo, sseguro, cagente, femisio,
                               fefecto, fvencim, ctiprec, cestaux,
                               nanuali, nfracci, ccobban, cestimp,
                               cempres, cdelega, nriesgo, ncuacoa,
                               ctipcoa, cestsop, cgescob)
                       VALUES (psproces, v_rec, psseguro, r_rec.cagente, f_sysdate,
                               r_rec.fefecto, r_rec.fvencim, v_ctiprec, xcestaux,
                               r_rec.nanuali, r_rec.nfracci, r_rec.ccobban, r_rec.cestimp,
                               r_rec.cempres, r_rec.cdelega, r_rec.nriesgo, r_rec.ncuacoa,
                               r_rec.ctipcoa, r_rec.cestsop, r_rec.cgescob);
               END IF;

               -- Buscamos el porcentaje local si es un coaseguro.
               vpas := 1220;

               IF r_rec.ctipcoa != 0 THEN
                  BEGIN
                     SELECT MAX(c.ploccoa)
                       INTO xploccoa
                       FROM coacuadro C, seguros s
                      WHERE C.ncuacoa = S.ncuacoa
                      AND   s.npoliza = pnpoliza
                      AND   s.ncertif = 0
                      AND c.sseguro = s.sseguro;
                  EXCEPTION
                     WHEN OTHERS THEN
                      xploccoa := NULL; --   RETURN 105447;
                  END;
               ELSE
                  xploccoa := NULL;
               END IF;

               vpas := 1230;

               SELECT MAX(pac_monedas.f_moneda_divisa(cdivisa))
                 INTO v_decimals
                 FROM seguros a, productos b
                WHERE a.sseguro = psseguro
                  AND b.sproduc = a.sproduc;

               vpas := 1240;

               SELECT MAX(itotalr)
                 INTO v_total
                 FROM vdetrecibos
                WHERE nrecibo = r_rec.nrecibo;

               vpas := 1250;

               FOR detrec IN cur_detrecibos(r_rec.nrecibo) LOOP
                  IF r_rtn.pretorno = 0 THEN
                     xiprianu2 := 0;
                  ELSE
                     vpas := 1260;
                      --Bug 29417/161655 - 18/12/2013 - AMC
                     /*IF v_ctiprec = 15 THEN
                        SELECT NVL(SUM(iconcep), 0)
                          INTO vsum85
                          FROM detrecibos
                         WHERE nrecibo = r_rec.nrecibo
                           AND cconcep = 85;

                        xiprianu2 := (detrec.iconcep + vsum85) *(r_rtn.pretorno / 100);
                     ELSE
                        xiprianu2 := detrec.iconcep *(r_rtn.pretorno / 100);
                     END IF;*/

                     xiprianu2 := detrec.iconcep *(r_rtn.pretorno / 100);
                  --Fi Bug 29417/161655 - 18/12/2013 - AMC
                  END IF;

                  vpas := 1270;
                  v_numerr := f_insdetrec(v_rec, 0, xiprianu2, xploccoa, detrec.cgarant,
                                          detrec.nriesgo, r_rec.ctipcoa, detrec.cageven,
                                          -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
                                          /*detrec.nmovima, 0, 0, 1, NULL, NULL, NULL,
                                          v_decimals);
                                          */
                                          detrec.nmovima, 0, 0, 1, xiprianu2, SYSDATE, NULL,
                                          v_decimals);
                                         IF v_numerr <> 0 THEN
                                           p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_GENERAR_RETORNO_POS', 1, 'ERROR F_INSDETRECIBO v_numerr: ' || v_numerr, SQLERRM);
                                         END IF;
                                          -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo

                  IF NVL(v_numerr, 0) <> 0 THEN
                     RAISE e_error_proc;
                  END IF;
               END LOOP;

               vpas := 1280;
               v_numerr := f_vdetrecibos(pmodo, v_rec, psproces);

               IF NVL(v_numerr, 0) <> 0 THEN
                  RAISE e_error_proc;
               END IF;
            END LOOP;
         END IF;
      END LOOP;

      vpas := 1290;
        BEGIN
        DELETE FROM DETRECIBOS  WHERE NRECIBO = v_rec AND CCONCEP <> 0;
        COMMIT;
        EXCEPTION WHEN OTHERS THEN
           NULL;
        END;
      RETURN v_numerr;
   EXCEPTION
      WHEN e_error_proc THEN
         IF c_retrn%ISOPEN THEN
            CLOSE c_retrn;
         END IF;

         IF cur_recibos%ISOPEN THEN
            CLOSE cur_recibos;
         END IF;

         IF cur_detrecibos%ISOPEN THEN
            CLOSE cur_detrecibos;
         END IF;

         RETURN v_numerr;
      WHEN OTHERS THEN
         IF c_retrn%ISOPEN THEN
            CLOSE c_retrn;
         END IF;

         IF cur_recibos%ISOPEN THEN
            CLOSE cur_recibos;
         END IF;

         IF cur_detrecibos%ISOPEN THEN
            CLOSE cur_detrecibos;
         END IF;

         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 9904162;
   END f_generar_retorno_pos;

FUNCTION f_agruparecibo_pos(pnpoliza number,
      psproduc IN NUMBER,
      pfecha IN DATE,
      pfemisio IN DATE,
      pcempres IN NUMBER,
      plistarec IN t_lista_id DEFAULT NULL,
      pctiprec IN NUMBER DEFAULT 3,
      pextornn IN NUMBER DEFAULT 0,
      pcommitpag IN NUMBER DEFAULT 1,
      pctipapor IN NUMBER DEFAULT NULL,
      pctipaportante IN NUMBER DEFAULT NULL)
--Bug.: 15708 - ICV - 08/06/2011 - Se aniade el tipo de recibo para poder agrupar recibos que no sean de cartera)
   RETURN NUMBER IS
      pnrecibo       recibos_comp.nrecibo%TYPE;
      --       pnrecibo       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vpfecha        DATE;

      TYPE assoc_array_recunif IS TABLE OF NUMBER
         INDEX BY VARCHAR2(200);

      vrecunif       assoc_array_recunif;
      vnpoliza       NUMBER;
      num_err        NUMBER;
      vsseguro       recibos.sseguro%TYPE;
      --       vsseguro       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vcagente       seguros.cagente%TYPE;
      --       vcagente       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vccobban       seguros.ccobban%TYPE;
      --       vccobban       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vcbancar       seguros.cbancar%TYPE;
--       vcbancar       VARCHAR2(34); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vctiprec       NUMBER;
      vnmovimi       recibos.nmovimi%TYPE;
      --       vnmovimi       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vcestimp       recibos.cestimp%TYPE;
      --       vcestimp       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vfvencim       DATE;
      vfefecto       DATE;
      vtraza         NUMBER;
      -- Modalidad pasando un listado de recibos
      vrecibos       VARCHAR2(8000);
      v_sel          VARCHAR2(8000);
      v_sproduc      VARCHAR2(20);
      --
      vfemisio       DATE;
      -- BUG22839:DRA:05/11/2012:Inici
      vnrecibo       recibos.nrecibo%TYPE;
      vcempres       recibos.cempres%TYPE;
      pcestrec       movrecibo.cestrec%TYPE;
      xcestrec       movrecibo.cestant%TYPE;
      -- ini BUG 0026035 - 12/02/2013 - JMF
      d_eferec       recibos.fefecto%TYPE;
      d_emirec       recibos.femisio%TYPE;
      n_movrec       movrecibo.smovrec%TYPE;
      d_fmovim       recibos.fefecto%TYPE;
      v_obj          VARCHAR2(500) := 'pac_gestion_rec.f_agruparecibo';
      v_par          VARCHAR2(500)
         := 'pro=' || psproduc || ' fec=' || pfecha || ' emi=' || pfemisio || ' emp='
            || pcempres || ' tip=' || pctiprec;
      -- fin BUG 0026035 - 12/02/2013 - JMF
      v_signo        NUMBER;   -- Bug 26022 - APD - 18/02/2013
      v_cestrec      movrecibo.cestrec%TYPE;
      -- Bug 26022 - APD - 18/02/2013
      v_fmovdia      movrecibo.fmovdia%TYPE;
      -- Bug 26022 - APD - 18/02/2013
      v_sperson      recibos.sperson%TYPE;
      v_grabasperson NUMBER(1) := 0;

      -- BUG22839:DRA:05/11/2012:Fi
      TYPE t_cursor IS REF CURSOR;

      c_rebuts       t_cursor;
      /*TYPE registre IS RECORD(
         npoliza        seguros.npoliza%TYPE,
         nrecibo        recibos.nrecibo%TYPE,
         iprinet        vdetrecibos.iprinet%TYPE,
         itotalr        vdetrecibos.itotalr%TYPE,
         icomcia        vdetrecibos.icomcia%TYPE,
         itotimp        vdetrecibos.icomcia%TYPE,
         itotcon        vdetrecibos.itotcon%TYPE,
         sperson        recibos.sperson%TYPE,
         nrecunif       adm_recunif.nrecunif%TYPE
      );

      rec            registre;*/
      v_polpol       seguros.npoliza%TYPE;
      v_perper       recibos.sperson%TYPE;
      v_uniuni       adm_recunif.nrecunif%TYPE;
      v_recrec       recibos.nrecibo%TYPE;
      v_nrec_dif_unifrec NUMBER;
      v_agr_max_fechas NUMBER;
      v_pneta        NUMBER;   -- BUG 0038217 - FAL - 30/11/2015
      Pvfvencim       DATE;
      NPRETORNO       NUMBER(5,2);
      -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
      v_recpw         VARCHAR(50);
      v_valrecibo     NUMBER;
      v_valor         number;
      v_coapos        NUMBER:=0;
      v_ret1          NUMBER;
      v_ret2          NUMBER;
      v_nrecibo       NUMBER;
      v_coacedido     NUMBER;
      -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
-----------------------------------------
      CURSOR c_recunif(csproduc NUMBER, ppfecha DATE) IS
         SELECT s.npoliza, r.*, v.iprinet, v.itotalr, v.icomcia, v.itotimp, v.itotcon
           FROM recibos r, seguros s, vdetrecibos v
          WHERE r.ctiprec = pctiprec
            AND r.cestaux = 1 -- Los de cartera de productos colectivos con
                                -- certificados se deberan crear en este estado
            AND r.fefecto <= ppfecha
            AND s.npoliza = pnpoliza
            AND r.sseguro = s.sseguro
            -- AND NVL(r.ctipapor,0) = NVL(pctipapor, NVL(r.ctipapor,0))
            AND s.sproduc = csproduc
            -- INICIO - 12/11/2020 - Company - Ar 37845 Incidencias Preproduccion Revision Movimientos PW vs iAXIS
            --AND ((pctiprec = 0 AND r.esccero = 1) OR  
            AND ((pctiprec = 1 AND r.esccero = 1) OR  
            -- FIN - 12/11/2020 - Company - Ar 37845 Incidencias Preproduccion Revision Movimientos PW vs iAXIS
             (pctiprec = 9 AND r.esccero <> 1))  -- del certificado 0
            AND r.nrecibo = v.nrecibo
            AND NVL(f_cestrec(r.nrecibo, NULL), 0) = 0
            -- que no esten cobrados
            AND r.nrecibo NOT IN(SELECT nrecibo
                                   FROM adm_recunif)
                                   ;

      --BUG 14438 - JTS - 12/05/2010
      CURSOR c_detrecibo(ppnrecibo NUMBER) IS
         SELECT   d.nrecibo, d.cconcep, d.cgarant, d.nriesgo,
                  SUM(DECODE(pctiprec,
                             9, d.iconcep,
                             13, d.iconcep,
                             DECODE(r.ctiprec, 9,(-1) * d.iconcep, d.iconcep))) iconcep
             FROM detrecibos d, recibos r
            WHERE d.nrecibo = ppnrecibo
              AND r.nrecibo = d.nrecibo
         GROUP BY d.nrecibo, d.cconcep, d.cgarant, d.nriesgo;

      CURSOR c_detrecibo_neg(ppnrecibo NUMBER) IS
         SELECT   d.nrecibo, d.cconcep, d.cgarant, d.nriesgo,
                  SUM(DECODE(r.ctiprec, 9,(-1) * d.iconcep, d.iconcep)) iconcep
             FROM detrecibos d, recibos r
            WHERE d.nrecibo = ppnrecibo
              AND r.nrecibo = d.nrecibo
         GROUP BY d.nrecibo, d.cconcep, d.cgarant, d.nriesgo;
   BEGIN

      vpfecha := NVL(pfecha, f_sysdate);
      vfemisio := NVL(pfemisio, f_sysdate);
      v_nrec_dif_unifrec := NVL(pac_parametros.f_parempresa_n(pcempres, 'NREC_DIF_UNIFREC'),0);
      v_agr_max_fechas := NVL(f_parproductos_v(psproduc, 'AGR_MAX_FECHAS'), 0);

      BEGIN
          SELECT c.pretorno
          INTO NPRETORNO
          FROM rtn_convenio c,seguros s
          WHERE c.sseguro = s.sseguro
          AND   s.npoliza = pnpoliza
          AND   s.ncertif = 0
            AND(c.nmovimi = NULL
                OR(NULL IS NULL
                   AND c.nmovimi = (SELECT MAX(m.nmovimi)
                                      FROM rtn_convenio m
                                     WHERE m.sseguro = S.sseguro)));
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NPRETORNO := 0;
     END;


      IF plistarec IS NULL THEN
         vtraza := 1;

         FOR regs IN c_recunif(psproduc, vpfecha) LOOP
         Pvfvencim := regs.FVENCIM;

            IF vrecunif.EXISTS(regs.npoliza) THEN
               vtraza := 2;
               -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
               BEGIN
                 SELECT cusuari
                 INTO v_recpw
                 FROM movrecibo
                 WHERE nrecibo = regs.nrecibo
                 AND smovrec = (select max(smovrec) from recibos where nrecibo = regs.nrecibo);
               EXCEPTION
                 WHEN OTHERS THEN
                   NULL;
               END;
               IF v_recpw = 'AXIS' OR v_recpw = 'AXIS_POS' then
               -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo

               -- Insertamos en tabla de detalle de agrupacion
               INSERT INTO adm_recunif
                           (nrecibo, nrecunif)
                    VALUES (regs.nrecibo, vrecunif(regs.npoliza));

                END IF;
            ELSE
               vtraza := 3;

               -- Obtenemos numero de recibo que agrupa los recibos
               -- pequeyitos
               -- BUG18054:DRA:23/03/2011:Inici
               IF v_nrec_dif_unifrec = 0 THEN
                  pnrecibo := pac_adm.f_get_seq_cont(pcempres);
               ELSE
                  pnrecibo := pac_adm.f_get_seq_cont(NULL);
               END IF;

               -- BUG18054:DRA:23/03/2011:Fi
               vrecunif(regs.npoliza) := pnrecibo;
               -- Insertamos en tabla de detalle de agrupacion
               -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
               BEGIN
                 SELECT cusuari
                 INTO v_recpw
                 FROM movrecibo
                 WHERE nrecibo = regs.nrecibo
                 AND smovrec = (select max(smovrec) from recibos where nrecibo = regs.nrecibo);
               EXCEPTION
                 WHEN OTHERS THEN
                   NULL;
               END;
               IF v_recpw = 'AXIS' OR v_recpw = 'AXIS_POS' then
               -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo

               INSERT INTO adm_recunif
                           (nrecibo, nrecunif)
                    VALUES (regs.nrecibo, vrecunif(regs.npoliza));

               -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
               END IF;
               -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
            END IF;
         END LOOP;
      ELSE
         vtraza := 4;

         FOR reg IN plistarec.FIRST .. plistarec.LAST LOOP
            SELECT s.npoliza, r.sperson, a.nrecunif, r.nrecibo
              INTO v_polpol, v_perper, v_uniuni, v_recrec
              FROM recibos r, seguros s, vdetrecibos v, adm_recunif a
             WHERE r.nrecibo = plistarec(reg).idd
               AND r.sseguro = s.sseguro
               AND r.nrecibo = v.nrecibo
               AND r.nrecibo = a.nrecibo(+);
            IF v_uniuni IS NULL THEN
               --miramos si los recibos son de la misma persona, caso retornos
               IF v_sperson IS NOT NULL THEN
                  IF v_perper IS NULL
                     OR v_sperson <> v_perper THEN
                     v_grabasperson := 1;
                  END IF;
               ELSIF v_grabasperson = 0 THEN
                  v_sperson := v_perper;
               END IF;

               IF vrecunif.EXISTS(v_polpol) THEN
                  vtraza := 9;

                  -- Insertamos en tabla de detalle de agrupacion
                  INSERT INTO adm_recunif
                              (nrecibo, nrecunif)
                       VALUES (v_recrec, vrecunif(v_polpol));

               ELSE
                  vtraza := 10;

                  -- Obtenemos numero de recibo que agrupa los recibos
                  -- pequeyitos
                  -- BUG18054:DRA:23/03/2011:Inici
                  IF v_nrec_dif_unifrec = 0 THEN
                     pnrecibo := pac_adm.f_get_seq_cont(pcempres);
                  ELSE
                     pnrecibo := pac_adm.f_get_seq_cont(NULL);
                  END IF;

                  vtraza := 11;
                  -- BUG18054:DRA:23/03/2011:Fi
                  vrecunif(v_polpol) := pnrecibo;

                  -- Insertamos en tabla de detalle de agrupacion
                  INSERT INTO adm_recunif
                              (nrecibo, nrecunif)
                       VALUES (v_recrec, vrecunif(v_polpol));

               END IF;
            END IF;
         END LOOP;
      END IF;

      vtraza := 12;
      -- Aqui debemos insertar el recibo 'grande' con el total de los recibos pequeyitos.
      vnpoliza := vrecunif.FIRST;

      LOOP
         EXIT WHEN vnpoliza IS NULL;
         vtraza := 13;
         vctiprec := pctiprec;

         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                              'CRITERIO_UNIFREC'),
                0) = 1 THEN   -- BUG 0038346 - FAL - 03/11/2015
            SELECT sseguro, cagente, ccobban, cbancar
              INTO vsseguro, vcagente, vccobban, vcbancar
              FROM seguros
             WHERE npoliza = vnpoliza
               AND sseguro = (SELECT DISTINCT sseguro
                                         FROM recibos
                                        WHERE nrecibo IN(SELECT nrecibo
                                                           FROM adm_recunif
                                                          WHERE nrecunif = vrecunif(vnpoliza)));
         ELSE
            SELECT sseguro, cagente, ccobban, cbancar
              INTO vsseguro, vcagente, vccobban, vcbancar
              FROM seguros
             WHERE npoliza = vnpoliza
               AND ncertif = 0;
         END IF;

         vtraza := 14;

         -- No se genera movimiento de seguro. Se busca
         -- el ultimo movimiento vigente
         --num_err := f_buscanmovimi(vsseguro, 1, 2, vnmovimi);
         -- Bug 10613 - 06/07/2009 - RSC - Ajustes en productos de Salud
         -- ultimo movimiento del certificado
         SELECT MAX(nmovimi)
           INTO vnmovimi
           FROM movseguro
          WHERE sseguro = vsseguro;

         -- Fin Bug 10613
         vtraza := 15;

         IF plistarec IS NULL THEN
            vtraza := 16;

            IF v_agr_max_fechas = 1 THEN
               SELECT MAX(r2.fefecto), MAX(r2.femisio), MAX(r2.fvencim)
                 INTO vfefecto, vfemisio, vfvencim
                 FROM recibos r2
                WHERE r2.nrecibo IN(SELECT r.nrecibo
                                      FROM recibos r, seguros s, vdetrecibos v
                                     WHERE r.cestaux = 2
                                       AND r.fefecto <= vpfecha
                                       AND r.sseguro = s.sseguro
                                       -- AND s.sproduc = psproduc
                                       AND r.esccero = 1
                                       AND r.nrecibo = v.nrecibo
                                       AND s.npoliza = vnpoliza
                                       AND r.nrecibo IN(SELECT nrecibo
                                                          FROM adm_recunif
                                                         WHERE nrecunif = vrecunif(vnpoliza)));
            ELSE
               SELECT MIN(r2.fefecto), MAX(r2.fvencim)
                 INTO vfefecto, vfvencim
                 FROM recibos r2
                WHERE r2.nrecibo IN(SELECT r.nrecibo
                                      FROM recibos r, seguros s, vdetrecibos v
                                     WHERE r.cestaux = 2
                                       AND r.fefecto <= vpfecha
                                       AND r.sseguro = s.sseguro
                                       -- AND s.sproduc = psproduc
                                       AND r.esccero = 1
                                       AND r.nrecibo = v.nrecibo
                                       AND s.npoliza = vnpoliza
                                       AND r.nrecibo IN(SELECT nrecibo
                                                          FROM adm_recunif
                                                         WHERE nrecunif = vrecunif(vnpoliza)));
            END IF;
         ELSE
            vtraza := 18;

            -- Bug 19096 - RSC - 03/08/2011 - LCOL - Parametrizacion basica producto Vida Individual Pagos Permanentes
            -- Borramos: AND r.esccero = 1 (no lo creemos necesarios en esta modalidad de ejecucion)
            IF v_agr_max_fechas = 1 THEN
               SELECT MAX(r2.fefecto), MAX(r2.femisio), MAX(r2.fvencim)
                 INTO vfefecto, vfemisio, vfvencim
                 FROM recibos r2
                WHERE r2.nrecibo IN(SELECT r.nrecibo
                                      FROM recibos r, seguros s, vdetrecibos v
                                     WHERE r.sseguro = s.sseguro
                                       --AND r.cestaux = 2 -- 22. 0022763 Unificacion / Desunificacion de recibos - 0119028
                                       --AND r.esccero = 1 -- Bug 19096 - RSC - 03/08/2011
                                       AND r.nrecibo = v.nrecibo
                                       AND s.npoliza = vnpoliza
                                       AND r.nrecibo IN(SELECT nrecibo
                                                          FROM adm_recunif
                                                         WHERE nrecunif = vrecunif(vnpoliza)));
            ELSE
               SELECT MIN(r2.fefecto), MAX(r2.fvencim)
                 INTO vfefecto, vfvencim
                 FROM recibos r2
                WHERE r2.nrecibo IN(SELECT r.nrecibo
                                      FROM recibos r, seguros s, vdetrecibos v
                                     WHERE r.sseguro = s.sseguro
                                       --AND r.cestaux = 2 -- 22. 0022763 Unificacion / Desunificacion de recibos - 0119028
                                       --AND r.esccero = 1 -- Bug 19096 - RSC - 03/08/2011
                                       AND r.nrecibo = v.nrecibo
                                       AND s.npoliza = vnpoliza
                                       AND r.nrecibo IN(SELECT nrecibo
                                                          FROM adm_recunif
                                                         WHERE nrecunif = vrecunif(vnpoliza)));
            END IF;

            vtraza := 19;
         END IF;

         vtraza := 20;

         IF vcbancar IS NOT NULL
            AND vccobban IS NOT NULL THEN   -- BUG22839:DRA:05/11/2012
            vcestimp := 4;
         ELSE
            vcestimp := 1;
         END IF;

         vtraza := 21;

         -- Insertamos el nuevo recibo 'grande'

         -- Bug 19096 - RSC - 03/08/2011 - LCOL - Parametrizacion basica producto Vida Individual Pagos Permanentes
         -- IF plistarec IS NULL THEN -- 22. 0022763 / 0119028 - (segun DRA)
            -- Fin 19096
         -- INICIO - 12/11/2020 - Company - Ar 37845 Incidencias Preproduccion Revision Movimientos PW vs iAXIS
         --IF vctiprec = 0 THEN
         IF vctiprec = 1 THEN
         -- FIN - 12/11/2020 - Company - Ar 37845 Incidencias Preproduccion Revision Movimientos PW vs iAXIS
             vctiprec := 13;
         ELSIF vctiprec = 9 THEN
             vctiprec := 15;
         END IF;

         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                              'CRITERIO_UNIFREC'),
                0) = 1 THEN   -- BUG 0038346 - FAL - 03/11/2015

            num_err := f_insrecibo(vsseguro, vcagente, NVL(vfemisio,pfemisio), NVL(vfefecto,pfecha), NVL(vfvencim,Pvfvencim), vctiprec,
                                   NULL, NULL, vccobban, vcestimp, 1, vrecunif(vnpoliza), 'R',
                                   NULL, NULL, vnmovimi, TRUNC(f_sysdate), NULL);



            IF num_err <> 0 THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.f_agruparecibo_pos', 1, 'ERROR F_INSRECIBO (retorno) NUM_ERR: ' || NUM_ERR, SQLERRM);
              RETURN num_err;
            END IF;

         ELSE
           -- INICIO - 12/11/2020 - Company - Ar 37845 Incidencias Preproduccion Revision Movimientos PW vs iAXIS
           IF vctiprec IN (13, 15) THEN
             BEGIN
               SELECT FCARPRO
               INTO vfvencim
               FROM seguros 
               WHERE sseguro = vsseguro;
             EXCEPTION
               WHEN OTHERS THEN
                 p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT FCARPRO SEGUROS ', SQLERRM);
             END;    
           END IF;
           -- FIN - 12/11/2020 - Company - Ar 37845 Incidencias Preproduccion Revision Movimientos PW vs iAXIS
            -- INSERTA EL RECIBO DE RETORNO O RECOBRO DEL RETORNO POR TOMADOR EN CARATULA
            num_err := f_insrecibo(vsseguro, vcagente, NVL(vfemisio,pfemisio), NVL(vfefecto,pfecha), NVL(vfvencim,Pvfvencim), vctiprec,
                                   NULL, NULL, vccobban, vcestimp, 1, vrecunif(vnpoliza), 'R',
                                   NULL, NULL, vnmovimi, TRUNC(f_sysdate), 'CERTIF0');
            IF num_err <> 0 THEN
              p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.f_agruparecibo_pos', 1, 'ERROR F_INSRECIBO 2 (retorno) NUM_ERR: ' || NUM_ERR, SQLERRM);
              RETURN num_err;
            END IF;
            -- INICIO - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP
            BEGIN
              INSERT INTO msv_recibos(id_cargue,proceso,recibo,estado)
                   VALUES(v_idcargue, v_sproces, vrecunif(vnpoliza), 0);
            EXCEPTION
              WHEN OTHERS THEN
                p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR INSERT MSV_RECIBOS ', SQLERRM);
            END;
            -- FIN - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP


         END IF;

         vtraza := 22;

         IF num_err <> 0 THEN
            RETURN num_err;
         ELSE
            IF v_grabasperson = 0 THEN
               UPDATE recibos
                  SET sperson = v_sperson
                WHERE nrecibo = vrecunif(vnpoliza);
            END IF;
         END IF;

         -- Fin 19096
         IF num_err <> 0 THEN
            RETURN num_err;
         ELSE
            vtraza := 23;

            BEGIN
               -- Pomes CESTAUX = 0 ya que el recibo grande si queremos procesarlo
               UPDATE recibos
                  SET cestaux = 0,
                      -- cestimp = vcestimp,
                      cmanual = 1,
                      cbancar = vcbancar,
                      ccobban = vccobban,
                      ctipapor = NVL(pctipapor, ctipapor),
                      ctipaportante = NVL(pctipaportante, ctipaportante)
                WHERE nrecibo = vrecunif(vnpoliza);
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 102358;
            END;

            vtraza := 24;

            -- Obtenemos los recibos pequeyitos de una poliza
            -- (por si tenemos que hacer algo con ellos)

            IF plistarec IS NULL THEN
               vtraza := 25;
/*
for y in (select r.nrecibo, r.ctiprec, d.cconcep, d.iconcep, d.nriesgo, d.cgarant
                                FROM adm_recunif a, recibos r, detrecibos d
                               WHERE a.nrecunif = vrecunif(vnpoliza)
                                 AND a.nrecibo = r.nrecibo
                                 AND a.nrecibo = d.nrecibo
                                 AND ((vctiprec = 13 and r.esccero = 1) or (vctiprec = 15 and r.esccero <> 1))
                                 AND r.fefecto <= vpfecha
                            GROUP BY d.cconcep, d.nriesgo, d.cgarant) loop

end loop;
*/

               FOR regs IN (SELECT   d.cconcep, d.nriesgo, d.cgarant,
                                     (SUM(DECODE(pctiprec,
                                                9, DECODE(r.ctiprec,
                                                          9, d.iconcep,
                                                          (-1) * d.iconcep),
                                                13, DECODE(r.ctiprec,
                                                           13, d.iconcep,
                                                           (-1) * d.iconcep),
                                                DECODE(r.ctiprec,
                                                       9,(-1) * d.iconcep,
                                                       d.iconcep))) * NPRETORNO ) / 100 iconcep
                                FROM adm_recunif a, recibos r, detrecibos d
                               WHERE a.nrecunif = vrecunif(vnpoliza)
                                 AND a.nrecibo = r.nrecibo
                                 AND a.nrecibo = d.nrecibo
                                 AND ((vctiprec = 13 and r.esccero = 1) or (vctiprec = 15 and r.esccero <> 1))
                                 AND r.fefecto <= vpfecha
                            GROUP BY d.cconcep, d.nriesgo, d.cgarant) LOOP
                  -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
                  IF (vctiprec = 13 OR vctiprec = 15) AND regs.cconcep = 0 THEN

                    INSERT INTO detrecibos
                              (nrecibo, cconcep, cgarant, nriesgo,
                               iconcep)
                       VALUES (vrecunif(vnpoliza), 0, regs.cgarant, regs.nriesgo,
                               round(regs.iconcep));
                  ELSIF vctiprec = 0 THEN

                  INSERT INTO detrecibos
                              (nrecibo, cconcep, cgarant, nriesgo,
                               iconcep)
                       VALUES (vrecunif(vnpoliza), regs.cconcep, regs.cgarant, regs.nriesgo,
                               round(regs.iconcep));
                  END IF;
                  END LOOP;
                  BEGIN
                    SELECT sum(pcescoa)
                      INTO v_coacedido
                      FROM coacedido
                     WHERE sseguro = (select sseguro from seguros where npoliza = vnpoliza and ncertif = 0)
                       AND ncuacoa = (SELECT MAX(ncuacoa) FROM coacedido WHERE sseguro = vsseguro);
                  EXCEPTION
                    WHEN OTHERS THEN
                      v_coacedido := 0;
                  END;
                  IF nvl(v_coacedido,0) > 0 THEN
                    v_coacedido := v_coacedido / 100;
                    v_coapos := 1 - v_coacedido;
                  END IF;

                  IF NVL(v_coapos,0) > 0 AND vctiprec IN (13,15) THEN
                    FOR i IN (SELECT CGARANT , nriesgo, SUM(ICONCEP) VALCONCEP 
                                FROM DETRECIBOS 
                               WHERE  NRECIBO = (SELECT NRECIBO FROM ADM_RECUNIF WHERE NRECUNIF = vrecunif(vnpoliza)) 
                                 AND CCONCEP IN (0,50) 
                               GROUP BY CGARANT, nriesgo)
                    LOOP
                      v_ret1 := i.VALCONCEP * (NPRETORNO / 100);
                      v_ret2 := v_ret1 * v_coapos;
                      v_ret1 := v_ret1 - round(v_ret2);
                      v_ret1 := round(v_ret1);


                      INSERT INTO detrecibos(nrecibo, cconcep, cgarant, nriesgo,iconcep)
                      VALUES (vrecunif(vnpoliza), 50, i.cgarant, i.nriesgo,v_ret1);
                    END LOOP;

                  END IF;
                  -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
                  -- BUG 26488_0143335 - JLTS - 25/04/2013 - ini
            --UPDATE detrecibos
            --SET iconcep = ABS(iconcep)
            --WHERE nrecibo = vrecunif(vnpoliza);
               -- BUG 26488_0143335 - JLTS - 25/04/2013 - fin
            ELSE
               vtraza := 26;
               --En los recibos de extorno los conceptos negativos son a cobrar (positivos) y los conceptos positivos son a pagar.
               --En los recibos a cobrar, los conceptos negativos son a pagar (extornos) y los conceptos positivos son a cobrar.
               FOR regs IN (SELECT   d.cconcep, d.nriesgo, d.cgarant,
                                     (SUM(DECODE(pctiprec,
                                                9, DECODE(r.ctiprec,
                                                          9, d.iconcep,
                                                          (-1) * d.iconcep),
                                                13, DECODE(r.ctiprec,
                                                           13, d.iconcep,
                                                           (-1) * d.iconcep),
                                                DECODE(r.ctiprec,
                                                       9,(-1) * d.iconcep,
                                                       d.iconcep))) * NPRETORNO) /100 iconcep
                                FROM adm_recunif a, recibos r, detrecibos d
                               WHERE a.nrecunif = vrecunif(vnpoliza)
                                 AND a.nrecibo = r.nrecibo
                                 AND a.nrecibo = d.nrecibo
                            GROUP BY d.cconcep, d.nriesgo, d.cgarant)  LOOP
                  INSERT INTO detrecibos
                              (nrecibo, cconcep, cgarant, nriesgo,
                               iconcep)
                       VALUES (vrecunif(vnpoliza), regs.cconcep, regs.cgarant, regs.nriesgo,
                               regs.iconcep);
               END LOOP;
                  -- BUG 26488_0143335 - JLTS - 25/04/2013 - ini
            --UPDATE detrecibos
            --SET iconcep = ABS(iconcep)
            --WHERE nrecibo = vrecunif(vnpoliza);
               -- BUG 26488_0143335 - JLTS - 25/04/2013 - fin
            END IF;

            -- BUG 0038217 - FAL - 30/11/2015 - Si el recibo agrupador es negativo (sea porque agrupa extornos, ...) invertir signo de los importes del detalle del recibo y ponerlo como de tipo extorno
            BEGIN
               SELECT SUM(iconcep)
                 INTO v_pneta
                 FROM detrecibos
                WHERE nrecibo = vrecunif(vnpoliza)
                  AND cconcep = 0;
            EXCEPTION
               WHEN OTHERS THEN
                  v_pneta := 0;
            END;

            IF v_pneta < 0 THEN
               UPDATE detrecibos
                  SET iconcep = iconcep *(-1)
                WHERE nrecibo = vrecunif(vnpoliza);

               UPDATE recibos
                  SET ctiprec = 15
                WHERE nrecibo = vrecunif(vnpoliza);
            END IF;

            -- FI BUG 0038217
            vtraza := 27;
            -- INICIO - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
            --num_err := f_vdetrecibos('R', vrecunif(vnpoliza));
            BEGIN
              SELECT ROUND(SUM(iconcep))
                INTO v_valrecibo
                FROM detrecibos 
               WHERE nrecibo = vrecunif(vnpoliza);
            EXCEPTION
              WHEN OTHERS THEN
                p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION SELECT SUM(ICONCEP) DETRECIBO' , SQLERRM);
            END;
              BEGIN
                Insert into VDETRECIBOS (NRECIBO,IPRINET,IRECEXT,ICONSOR,IRECCON,IIPS,IDGS,IARBITR,IFNG,IRECFRA,IDTOTEC,IDTOCOM,ICOMBRU,
                ICOMRET,IDTOOM,IPRIDEV,ITOTPRI,ITOTDTO,ITOTCON,ITOTIMP,ITOTALR,IDERREG,ITOTREC,ICOMDEV,IRETDEV,ICEDNET,ICEDREX,ICEDCON,
                ICEDRCO,ICEDIPS,ICEDDGS,ICEDARB,ICEDFNG,ICEDRFR,ICEDDTE,ICEDDCO,ICEDCBR,ICEDCRT,ICEDDOM,ICEDPDV,ICEDREG,ICEDCDV,ICEDRDV,
                IT1PRI,IT1DTO,IT1CON,IT1IMP,IT1REC,IT1TOTR,IT2PRI,IT2DTO,IT2CON,IT2IMP,IT2REC,IT2TOTR,ICOMCIA,ICOMBRUI,ICOMRETI,ICOMDEVI,
                ICOMDRTI,ICOMBRUC,ICOMRETC,ICOMDEVC,ICOMDRTC,IOCOREC,IIMP_1,IIMP_2,IIMP_3,IIMP_4,ICONVOLEODUCTO) 
                values (vrecunif(vnpoliza),v_valrecibo,'0','0','0','0','0','0','0','0','0','0','0','0','0',v_valrecibo,v_valrecibo,'0','0','0',v_valrecibo,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',v_valrecibo,'0','0','0','0',v_valrecibo,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');
              EXCEPTION
              WHEN OTHERS THEN
                p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT VDETRECIBOS DETRECIBO' , SQLERRM);
              END;
              BEGIN
                Insert into VDETRECIBOS_MONPOL (NRECIBO,IPRINET,IRECEXT,ICONSOR,IRECCON,IIPS,IDGS,IARBITR,IFNG,IRECFRA,IDTOTEC,IDTOCOM,
                ICOMBRU,ICOMRET,IDTOOM,IPRIDEV,ITOTPRI,ITOTDTO,ITOTCON,ITOTIMP,ITOTALR,IDERREG,ITOTREC,ICOMDEV,IRETDEV,ICEDNET,ICEDREX,
                ICEDCON,ICEDRCO,ICEDIPS,ICEDDGS,ICEDARB,ICEDFNG,ICEDRFR,ICEDDTE,ICEDDCO,ICEDCBR,ICEDCRT,ICEDDOM,ICEDPDV,ICEDREG,ICEDCDV,
                ICEDRDV,IT1PRI,IT1DTO,IT1CON,IT1IMP,IT1REC,IT1TOTR,IT2PRI,IT2DTO,IT2CON,IT2IMP,IT2REC,IT2TOTR,ICOMCIA,ICOMBRUI,ICOMRETI,
                ICOMDEVI,ICOMDRTI,ICOMBRUC,ICOMRETC,ICOMDEVC,ICOMDRTC,IOCOREC,IIMP_1,IIMP_2,IIMP_3,IIMP_4,ICONVOLEODUCTO) 
                values (vrecunif(vnpoliza),v_valrecibo,'0','0','0','0','0','0','0','0','0','0','0','0','0',v_valrecibo,v_valrecibo,'0','0','0',v_valrecibo,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',v_valrecibo,'0','0','0','0',v_valrecibo,'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');
              EXCEPTION
                WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'EXCEPCION INSERT VDETRECIBOS_MONPOL DETRECIBO' , SQLERRM);
              END;
              -- FIN - 27/10/2020 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            -- 37.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Inicio

            -- Cambiamos la manera de hacer el reparto de corretaje. Llamamos directamente a PAC_CORRETAJE.F_REPARTO_CORRETAJE

            -- 38.0 - 03/04/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion en polizas... Inicio
            IF pac_corretaje.f_tiene_corretaje(vsseguro, NULL) = 1 THEN
               num_err := pac_corretaje.f_reparto_corretaje(vsseguro, vnmovimi,
                                                            vrecunif(vnpoliza));
            END IF;

            -- 38.0 - 03/04/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion en polizas... Fin
            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            -- Bug 26022 - APD - 18/02/2013 - Liquidaciones de Colectivos
            -- Cuando se genera el recibo agrupado se ha de informar la COMRECIBO con la suma de los conceptos
            -- de cada uno de los recibos de los n-certificados para que la liquidacion, ya que se liquida a
            -- nivel de recibo agrupado, pueda tener informada la COMRECIBO
            /*IF pac_corretaje.f_tiene_corretaje(vsseguro, NULL) = 1 THEN
               FOR reg IN (SELECT   a.cagente, c.cgarant, SUM(c.icombru) icombru,
                                    SUM(c.icomret) icomret, SUM(c.icomdev) icomdev,
                                    SUM(c.iretdev) iretdev
                               FROM recibos r, age_corretaje a, comrecibo c
                              WHERE a.sseguro = r.sseguro
                                AND a.nmovimi = (SELECT MAX(a1.nmovimi)
                                                   FROM age_corretaje a1
                                                  WHERE a1.sseguro = a.sseguro
                                                    AND a1.cagente = a.cagente)
                                AND c.nrecibo = r.nrecibo
                                AND c.cagente = a.cagente
                                AND r.cestaux = 2
                                AND r.nrecibo IN(SELECT nrecibo
                                                   FROM adm_recunif
                                                  WHERE nrecunif = vrecunif(vnpoliza))
                           GROUP BY a.cagente, c.cgarant) LOOP
                  IF vctiprec = 9 THEN
                     v_signo := -1;
                  ELSE
                     v_signo := 1;
                  END IF;

                  SELECT m.cestrec, m.fmovdia
                    INTO v_cestrec, v_fmovdia
                    FROM movrecibo m
                   WHERE m.nrecibo = vrecunif(vnpoliza)
                     AND m.smovrec = (SELECT MAX(m1.smovrec)
                                        FROM movrecibo m1
                                       WHERE m1.nrecibo = m.nrecibo);

                  num_err := pac_comisiones.f_alt_comisionrec(vrecunif(vnpoliza), v_cestrec,
                                                              v_fmovdia, reg.icombru * v_signo,
                                                              reg.icomret * v_signo,
                                                              reg.icomdev * v_signo,
                                                              reg.iretdev * v_signo,
                                                              reg.cagente, reg.cgarant);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END LOOP;
            END IF;*/
            -- 37.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Fin

            -- fin Bug 26022 - APD - 18/02/2013 - Liquidaciones de Colectivos

            -- Siguiente poliza
            vnpoliza := vrecunif.NEXT(vnpoliza);
         END IF;

      END LOOP;

      vtraza := 28;

      --Bug.: 15708 - ICV - 09/06/2011
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'GESTIONA_COBPAG'), 0) = 1 THEN
         vnpoliza := vrecunif.FIRST;

         LOOP
            EXIT WHEN vnpoliza IS NULL;
            vnrecibo := vrecunif(vnpoliza);
            vtraza := 29;

            BEGIN
               SELECT r.cempres, r.sseguro, r.nmovimi, r.femisio, r.fefecto
                 INTO vcempres, vsseguro, vnmovimi, d_emirec, d_eferec
                 FROM recibos r
                WHERE r.nrecibo = vnrecibo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  num_err := 101902;
            -- Recibo no encontrado en la tabla RECIBOS
            END;

            vtraza := 30;

            BEGIN
               SELECT m.cestrec, m.cestant, m.smovrec
                 INTO pcestrec, xcestrec, n_movrec
                 FROM movrecibo m
                WHERE m.nrecibo = vnrecibo
                  AND m.fmovfin IS NULL;
            EXCEPTION
               WHEN OTHERS THEN
                  pcestrec := NULL;
                  xcestrec := NULL;
            END;

            IF NOT(pcestrec = 0
                   AND NVL(xcestrec, 0) = 0)   --SI NO ES EMISION
                                            THEN
               RETURN 0;
            END IF;

            vtraza := 31;

            -- ini BUG 0026035 - 12/02/2013 - JMF
            IF num_err = 0 THEN
               --BUG 23183-XVM-08/11/2012.Inicio
               IF d_emirec < d_eferec THEN
                  d_fmovim := d_eferec;
               ELSE
                  d_fmovim := d_emirec;
               END IF;

               num_err := f_insctacoas(vnrecibo, 1, vcempres, n_movrec, TRUNC(d_fmovim));

               IF num_err != 0 THEN
                  p_tab_error(f_sysdate, f_user, v_obj, vtraza,
                              'r=' || vnrecibo || ' m=' || n_movrec || ' f=' || d_fmovim
                              || ' ' || v_par,
                              num_err || ' - ' || SQLCODE);
                  RETURN num_err;
               END IF;
            END IF;

            --BUG 23183-XVM-08/11/2012.Fin
            -- fin BUG 0026035 - 12/02/2013 - JMF
            vtraza := 40;

			-- INICIO Ar 37224 Company 15102020
			/*
            IF pcommitpag = 1 THEN
               -- BUG22839:DRA:05/11/2012:Inici
               IF num_err = 0 THEN
                  num_err := pac_ctrl_env_recibos.f_proc_recpag_mov(vcempres, vsseguro,
                                                                    vnmovimi, 4, NULL);
               END IF;

               -- BUG22839:DRA:05/11/2012:Fi
               IF num_err <> 0 THEN
                  p_tab_error(f_sysdate, f_user, 'pac_gestion_rec.f_agruparecibo', vtraza,
                              'psproduc = ' || psproduc || ' pfecha = ' || pfecha
                              || ' pfemisio = ' || pfemisio || ' vcempres = ' || vcempres
                              || ' vcempres = ' || vcempres || ' vsseguro = ' || vsseguro
                              || ' vnmovimi = ' || vnmovimi || ' pcestrec = ' || pcestrec
                              || ' xcestrec = ' || xcestrec,
                              num_err || ' - ' || f_axis_literales(num_err, f_usu_idioma));
                  --Mira si borraar sin_tramita_movpago porque se tiene que hacer un commit para que loo vea el sap
                  RETURN num_err;
               END IF;
            END IF;
			*/
			-- FIN Ar 37224 Company 15102020

            vnpoliza := vrecunif.NEXT(vnpoliza);

         END LOOP;
      END IF;

      --Fi Bug.: 15708
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_agruparecibo', vtraza,
                     'psproduc = ' || psproduc || ' pfecha = ' || pfecha || ' pfemisio = '
                     || pfemisio || ' pcempres = ' || pcempres,
                     SQLERRM);
         RETURN 9901207;
   END f_agruparecibo_POS;


   FUNCTION f_generar_retorno_recob(
      pnpoliza IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnrecibo IN NUMBER,
      psproces IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R',
      ptipo IN VARCHAR2 DEFAULT 'NO')
      RETURN NUMBER IS
      vpas           NUMBER := 1;
      vobj           VARCHAR2(500) := 'PAC_POS_CARGUE.f_generar_retorno_recob';
      vpar           VARCHAR2(500)
         := 's=' || psseguro || ' n=' || pnmovimi || ' r=' || pnrecibo || ' p=' || psproces
            || ' m=' || pmodo;
      v_age          seguros.cagente%TYPE;
      v_pro          seguros.sproduc%TYPE;
      d_ini          DATE;
      d_fin          DATE;
      v_pol          seguros.npoliza%TYPE;
      v_numerr       NUMBER;
      v_idenew       rtn_mntconvenio.idconvenio%TYPE;
      v_cdomper      movseguro.cdomper%TYPE;
      v_ctiprec      recibos.ctiprec%TYPE;
      v_rec          recibos.nrecibo%TYPE;
      e_error_proc   EXCEPTION;
      xcestaux       NUMBER;
      xccobban       NUMBER;
      xcestimp       NUMBER;
      xcdelega       NUMBER;
      xcestsop       NUMBER;   -- generacion de soportes
      xcmanual       NUMBER(1);
      xnbancar       seguros.cbancar%TYPE;
      xnbancarf      seguros.cbancar%TYPE;
      xtbancar       seguros.cbancar%TYPE;
      dummy          NUMBER;
      xsmovrec       NUMBER;
      xnliqmen       NUMBER;
      xfmovim        DATE;
      v_ctipban      per_ccc.ctipban%TYPE;
      v_cbancar      per_ccc.cbancar%TYPE;
      xiprianu2      detrecibos.iconcep%TYPE;
      xploccoa       NUMBER;
      v_decimals     NUMBER := 0;
      xcmovimi       NUMBER;
      v_total        vdetrecibos.itotalr%TYPE;
      v_cuseraut     psucontrolseg.cusuaur%TYPE;
      xesccero       NUMBER(1);
      vsum85         NUMBER;
      vncertif       NUMBER;   --bug 29324/161385 - 16/12/2013 - AMC
      v_copago       pregunpolseg.crespue%TYPE;   -- BUG 27417 - MMS - 20140208
      vcuenta        NUMBER;   -- 29991/65385 - 05/02/2014

      CURSOR c_retrn(pc_sseguro IN NUMBER, pc_nmovimi IN NUMBER) IS
         SELECT c.sperson, c.nmovimi, c.pretorno
           FROM rtn_convenio c,seguros s
          WHERE c.sseguro = s.sseguro
          AND   s.npoliza = pnpoliza
          AND   s.ncertif = 0
            AND(c.nmovimi = pc_nmovimi
                OR(pc_nmovimi IS NULL
                   AND c.nmovimi = (SELECT MAX(m.nmovimi)
                                      FROM rtn_convenio m
                                     WHERE m.sseguro = S.sseguro)));

      CURSOR cur_recibos(pc_sseguro IN NUMBER, pc_nmovimi IN NUMBER, pc_nrecibo IN NUMBER) IS
         SELECT   r.*, s.sproduc produc, s.cagente AGENT, s.ctipreb tipreb, s.fcaranu caranu,
                  s.cagrpro agrpro, s.ncertif
             FROM recibos r, seguros s
            WHERE s.sseguro = pc_sseguro
              AND r.sseguro = s.sseguro
              AND(r.nmovimi = pc_nmovimi
                  OR pc_nmovimi IS NULL
                  OR pc_nrecibo IS NOT NULL)
              AND(r.nrecibo = pc_nrecibo
                  OR pc_nrecibo IS NULL)
              AND EXISTS(SELECT 1
                           FROM movrecibo m
                          WHERE m.nrecibo = r.nrecibo
                            AND m.cestrec = 0
                            AND m.fmovfin IS NULL)
              AND((NVL(r.cestaux, 0) IN(0, 2)   --BUG25357:DCT:07/01/2013:INICIO
                   AND r.ctipcoa <> 8)
                  OR(r.cestaux = 1
                     AND r.ctipcoa = 8))   --BUG25357:DCT:07/01/2013:FIN
              AND r.ctiprec NOT IN(13, 15)   -- BUG24271:DRA:16/11/2012
              AND R.ctiprec = 9
              AND NOT EXISTS(SELECT 1
                               FROM rtn_recretorno rtr
                              WHERE rtr.nrecibo = r.nrecibo)
         ORDER BY r.nrecibo;

      -- BUG 0025691 - 08/03/2013 - JMF: afegir 50,51
      CURSOR cur_detrecibos(pc_nrecibo IN NUMBER) IS
         SELECT   nriesgo, cgarant, cageven, nmovima, SUM(iconcep) iconcep
             FROM detrecibos
            WHERE nrecibo = pc_nrecibo
              AND cconcep IN(0, 8, 50, 58)   --Bug 27994 MCA incluir concepto de recargo fraccionamiento
         -- JLV Bug 31982, el retorno solo ha de tener en cuenta la prima y el recargo de fraccionamiento
         GROUP BY nriesgo, cgarant, cageven, nmovima;
   BEGIN
      vpas := 1000;
      IF pmodo = 'R' THEN
         IF psseguro IS NOT NULL THEN
            vpas := 1010;

            --bug 29324/161385 - 16/12/2013 - AMC
            SELECT cagente, sproduc, fefecto, npoliza, fcaranu, ncertif
              INTO v_age, v_pro, d_ini, v_pol, d_fin, vncertif
              FROM seguros
             WHERE sseguro = psseguro;

            vpas := 1020;

            IF vncertif = 0 THEN
               SELECT COUNT(1)
                 INTO v_numerr
                 FROM rtn_mntageconvenio a, rtn_mntprodconvenio b, rtn_mntconvenio c
                WHERE b.idconvenio = a.idconvenio
                  AND c.idconvenio = b.idconvenio
                  AND a.cagente = v_age
                  AND b.sproduc = v_pro
                  AND d_ini BETWEEN c.finivig AND c.ffinvig
                  -- BUG 0025691/0138159 - FAL - 20/02/2013
                  -- BUG 0025691 - 08/03/2013 - JMF: AND c.direcpol = 0
                  AND(c.direcpol = 0
                      OR(c.direcpol = 1
                         AND c.ccodconv = 'POL-' || v_pol));   --bug 29324/161385 - 16/12/2013 - AMC

               -- FI BUG 0025691/0138159
               IF v_numerr = 0 THEN
                  -- No existe el convenio, lo creamos.

                  -- buscar usuario que autoriza.
                  vpas := 1030;

                  SELECT MAX(cusuaur)
                    INTO v_cuseraut
                    FROM psucontrolseg a
                   WHERE sseguro = psseguro
                     AND ccontrol = 526051
                     AND nmovimi = (SELECT MAX(b.nmovimi)
                                      FROM psucontrolseg b
                                     WHERE b.sseguro = a.sseguro
                                       AND b.ccontrol = a.ccontrol);

                  vpas := 1040;
                  -- BUG 0025815 - 22/01/2013 - JMF: afegir sperson
                  v_numerr :=
                     pac_retorno.f_set_datconvenio
                                               (NULL, 'POL-' || v_pol,

                                                --'Directo desde poliza', d_ini, d_fin,
                                                f_axis_literales(9905021, f_usu_idioma), d_ini,
                                                d_fin,   -- BUG 0025691/0138159 - FAL - 20/02/2013
                                                --v_cuseraut, NULL, v_idenew);
                                                v_cuseraut, NULL, v_idenew, 1);   -- BUG 0025691/0138159 - FAL - 20/02/2013

                  IF NVL(v_numerr, 0) <> 0 THEN
                     RAISE e_error_proc;
                  END IF;

                  vpas := 1050;
                  v_numerr := pac_retorno.f_set_prodconvenio(v_idenew, v_pro);

                  IF NVL(v_numerr, 0) <> 0 THEN
                     RAISE e_error_proc;
                  END IF;

                  vpas := 1060;
                  v_numerr := pac_retorno.f_set_ageconvenio(v_idenew, v_age);

                  IF NVL(v_numerr, 0) <> 0 THEN
                     RAISE e_error_proc;
                  END IF;

                  vpas := 1070;

                  FOR f1 IN c_retrn(psseguro, NULL) LOOP
                     vpas := 1080;
                     -- BUG 0025580 - 08/01/2013 - JMF  : afegir ctomador

                     -- INICIO 23/01/2021 Company DESEMPLEO															
                     v_numerr := pac_retorno.f_set_benefconvenio(v_idenew, f1.sperson,
                     -- INICIO - 24/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
                                                                 --f1.pretorno);
                                                                 f1.pretorno, null);
                     -- FIN - 24/01/2021 - Company - AR 37681 - Incidencia prorateo recibo extorno cargue masivo
                     -- FIN 23/01/2021 Company DESEMPLEO

                     IF NVL(v_numerr, 0) <> 0 THEN
                        RAISE e_error_proc;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         --Fi bug 29324/161385 - 16/12/2013 - AMC
         END IF;
      END IF;

      v_numerr := 0;
      vpas := 1100;
      FOR r_rec IN cur_recibos(psseguro, pnmovimi, pnrecibo) LOOP
         vpas := 1110;

-- 29991/65385 - 05/02/2014 - INI
         SELECT COUNT(0)
           INTO vcuenta
           FROM detrecibos
          WHERE nrecibo =
                   r_rec.nrecibo   --BUG 0029991/166347 - 17/02/2014 - RCL - Canvi pnrecibo per r_rec.NRECIBO
            AND cconcep IN(0, 4, 8, 50, 54, 58, 86);

         IF vcuenta > 0 THEN
-- 29991/65385 - 05/02/2014 - FIN
            SELECT MAX(cdomper)
              INTO v_cdomper
              FROM movseguro
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi;

            IF r_rec.ctiprec = 9 THEN
               v_ctiprec := 15;   -- Recobro del Retorno
            ELSE
               v_ctiprec := 13;
            END IF;

            xsmovrec := 0;
            vpas := 1120;

            FOR r_rtn IN c_retrn(psseguro, NULL) LOOP
               vpas := 1130;
               v_rec := pac_adm.f_get_seq_cont(r_rec.cempres);
               -- <BUSCAR LOS DATOS BANCARIOS POR DEFECTO DEL BENEFICIARIO>
               vpas := 1140;
               SELECT MAX(ctipban), MAX(cbancar)
                 INTO v_ctipban, v_cbancar
                 FROM per_ccc a
                WHERE sperson = r_rtn.sperson
                  AND cnordban = (SELECT MAX(b.cnordban)
                                    FROM per_ccc b
                                   WHERE b.sperson = r_rtn.sperson
                                     AND b.cdefecto = 1);

               IF v_cbancar IS NULL THEN
                  vpas := 1150;

                  SELECT MAX(ctipban), MAX(cbancar)
                    INTO v_ctipban, v_cbancar
                    FROM per_ccc a
                   WHERE sperson = r_rtn.sperson
                     AND cnordban = (SELECT MAX(b.cnordban)
                                       FROM per_ccc b
                                      WHERE b.sperson = r_rtn.sperson);
               END IF;

               xcestaux := 0;

               -- INI RLLF 18/01/2016 0038732: POS ADM Recaudo y Cartera Ramo Salud

               /*IF NVL(f_parproductos_v(v_pro, 'ADMITE_CERTIFICADOS'), 0) = 1
                  AND NVL(f_parproductos_v(v_pro, 'RECUNIF'), 0) IN(1, 3) THEN
                  -- BUG26111:DRA:18/02/2013: Si es reunifica ha de quedar amb CESTAUX=2
                  --AND pac_seguros.f_es_col_admin(psseguro) = 1
                  --AND pac_seguros.f_get_escertifcero(NULL, psseguro) = 0 THEN
                  -- BUG26111:DRA:18/02/2013:Fi
                  xcestaux := 2;
               END IF;*/
              xcestaux := r_rec.cestaux;
               -- FIN RLLF 18/01/2016 0038732: POS ADM Recaudo y Cartera Ramo Salud

               IF pmodo = 'R' THEN
                  IF v_cbancar IS NOT NULL THEN
                     vpas := 1160;
                     xnbancar := v_cbancar;
                     v_numerr := f_ccc(xnbancar, v_ctipban, dummy, xnbancarf);
                     vpas := 1170;

                     IF v_numerr = 0
                        OR(v_numerr = 102493
                           AND f_parinstalacion_n('DIGICTRL00') = 1) THEN
                        xtbancar := v_cbancar;
                     ELSE
                        RETURN v_numerr;
                     END IF;
                  END IF;

                  IF NVL(ptipo, 'NO') = 'CERTIF0' THEN
                     xesccero := 1;
                  ELSE
                     xesccero := 0;

                     -- Inicio BUG 27417 - MMS - 20140208
                     IF r_rec.tipreb = 4 THEN
                        BEGIN
                           SELECT p1.crespue
                             INTO v_copago
                             FROM pregunpolseg p1
                            WHERE p1.sseguro = psseguro
                              AND p1.cpregun = 535
                              AND p1.nmovimi = (SELECT MAX(p2.nmovimi)
                                                  FROM pregunpolseg p2
                                                 WHERE p2.sseguro = p1.sseguro
                                                   AND p2.cpregun = p1.cpregun);
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              v_copago := NULL;
                        END;

                        IF NVL(v_copago, 100) <> 0 THEN
                           xesccero := 1;
                        END IF;
                     END IF;
                  -- Fin BUG 27417 - MMS - 20140208
                  END IF;

                  BEGIN
                     vpas := 1180;
                     -- INSERTA EL RECIBO DE RECOBRO DEL RETORNO EN RECIBO POR ASEGURADO EN CERTIFICADO
                     INSERT INTO recibos
                                 (nrecibo, sseguro, cagente, femisio,
                                  fefecto, fvencim, ctiprec, cestaux,
                                  nanuali, nfracci, ccobban, cestimp,
                                  cempres, cdelega, nriesgo, cforpag,
                                  cbancar, nmovimi, ncuacoa, ctipcoa,
                                  cestsop, nperven, cgescob, ctipban,
                                  cmanual, esccero, ctipcob, ncuotar,
                                  sperson)
                          VALUES (v_rec, psseguro, r_rec.cagente, r_rec.femisio,
                                  r_rec.fefecto, r_rec.fvencim, v_ctiprec, xcestaux,
                                  r_rec.nanuali, r_rec.nfracci, r_rec.ccobban, r_rec.cestimp,
                                  r_rec.cempres, r_rec.cdelega, r_rec.nriesgo, r_rec.cforpag,
                                  xtbancar, r_rec.nmovimi, r_rec.ncuacoa, r_rec.ctipcoa,
                                  r_rec.cestsop, r_rec.nperven, r_rec.cgescob, r_rec.ctipban,
                                  r_rec.cmanual, xesccero, r_rec.ctipcob, r_rec.ncuotar,
                                  r_rtn.sperson);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                      p_tab_error(f_sysdate, f_user, 'f_generar_retorno_recob102307', vpas,
                     'psseguro ' || psseguro ||
                              'pnpoliza' || pnpoliza||' r_rec.nrecibo: '||r_rec.nrecibo
                             ||' vcuenta: '||vcuenta||' ncertif: '||r_rec.ncertif||' v_ctiprec: '||v_ctiprec||' v_rec: '||v_rec,
                     SQLERRM);
                        RETURN 102307;   -- Registre duplicat a RECIBOS
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                    SQLCODE || ' - ' || SQLERRM);
                        RETURN 103847;   -- Error a l' inserir a RECIBOS
                  END;
                  -- INICIO - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP
                  BEGIN
                    INSERT INTO msv_recibos(id_cargue,proceso,recibo,estado)
                    VALUES(v_idcargue, v_sproces, v_rec, 0);
                  EXCEPTION
                    WHEN OTHERS THEN
                      p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_ALTA_CERTIF', 1, 'ERROR INSERT MSV_RECIBOS ', SQLERRM);
                  END;
                  -- FIN - 19/04/2021 - Company - Ar 39788 - Incidencias envio recibos a SAP
                  --BUG 24187 - 22/10/2012 - JRB - Se inserta la relacion del recibo con el retorno en la tabla rtn_recretorno
                  BEGIN
                     vpas := 1181;

                     INSERT INTO rtn_recretorno
                                 (nrecibo, nrecretorno)
                          VALUES (r_rec.nrecibo, v_rec);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        RETURN 9904388;   -- Registre duplicat a RECIBOS
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                    SQLCODE || ' - ' || SQLERRM);
                        RETURN 9904389;   -- Error a l' inserir a RECIBOS
                  END;

                  vpas := 1190;

                  IF f_sysdate < r_rec.fefecto THEN
                     xfmovim := r_rec.fefecto;
                  ELSE
                     xfmovim := f_sysdate;
                  END IF;

                  IF r_rec.agrpro = 2 THEN
                     xcmovimi := 2;   -- indica aportacion periodica
                  ELSE
                     xcmovimi := NULL;
                  END IF;

                  SELECT fmovini
                    INTO xfmovim
                    FROM movrecibo
                   WHERE nrecibo = r_rec.nrecibo
                     AND fmovfin IS NULL;

                  vpas := 1200;
                  v_numerr := f_movrecibo(v_rec, 0, NULL, xcmovimi, xsmovrec, xnliqmen, dummy,
                                          xfmovim, r_rec.ccobban, r_rec.cdelega, NULL, NULL);

                  IF NVL(v_numerr, 0) <> 0 THEN
                     RAISE e_error_proc;
                  END IF;
               ELSE
                  vpas := 1210;

                  INSERT INTO reciboscar
                              (sproces, nrecibo, sseguro, cagente, femisio,
                               fefecto, fvencim, ctiprec, cestaux,
                               nanuali, nfracci, ccobban, cestimp,
                               cempres, cdelega, nriesgo, ncuacoa,
                               ctipcoa, cestsop, cgescob)
                       VALUES (psproces, v_rec, psseguro, r_rec.cagente, f_sysdate,
                               r_rec.fefecto, r_rec.fvencim, v_ctiprec, xcestaux,
                               r_rec.nanuali, r_rec.nfracci, r_rec.ccobban, r_rec.cestimp,
                               r_rec.cempres, r_rec.cdelega, r_rec.nriesgo, r_rec.ncuacoa,
                               r_rec.ctipcoa, r_rec.cestsop, r_rec.cgescob);
               END IF;

               -- Buscamos el porcentaje local si es un coaseguro.
               vpas := 1220;

               IF r_rec.ctipcoa != 0 THEN
                  BEGIN
                     SELECT MAX(c.ploccoa)
                       INTO xploccoa
                       FROM coacuadro C, seguros s
                      WHERE C.ncuacoa = S.ncuacoa
                      AND   s.npoliza = pnpoliza
                      AND   s.ncertif = 0
                      AND c.sseguro = s.sseguro;
                  EXCEPTION
                     WHEN OTHERS THEN
                      xploccoa := NULL; --   RETURN 105447;
                  END;
               ELSE
                  xploccoa := NULL;
               END IF;

               vpas := 1230;

               SELECT MAX(pac_monedas.f_moneda_divisa(cdivisa))
                 INTO v_decimals
                 FROM seguros a, productos b
                WHERE a.sseguro = psseguro
                  AND b.sproduc = a.sproduc;

               vpas := 1240;

               SELECT MAX(itotalr)
                 INTO v_total
                 FROM vdetrecibos
                WHERE nrecibo = r_rec.nrecibo;

               vpas := 1250;

               FOR detrec IN cur_detrecibos(r_rec.nrecibo) LOOP
                  IF r_rtn.pretorno = 0 THEN
                     xiprianu2 := 0;
                  ELSE
                     vpas := 1260;
                      --Bug 29417/161655 - 18/12/2013 - AMC
                     /*IF v_ctiprec = 15 THEN
                        SELECT NVL(SUM(iconcep), 0)
                          INTO vsum85
                          FROM detrecibos
                         WHERE nrecibo = r_rec.nrecibo
                           AND cconcep = 85;

                        xiprianu2 := (detrec.iconcep + vsum85) *(r_rtn.pretorno / 100);
                     ELSE
                        xiprianu2 := detrec.iconcep *(r_rtn.pretorno / 100);
                     END IF;*/
                     xiprianu2 := detrec.iconcep *(r_rtn.pretorno / 100);
                  --Fi Bug 29417/161655 - 18/12/2013 - AMC
                  END IF;

                  vpas := 1270;
                  v_numerr := f_insdetrec(v_rec, 0, xiprianu2, xploccoa, detrec.cgarant,
                                          detrec.nriesgo, r_rec.ctipcoa, detrec.cageven,
                                          -- INICIO - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo
                                          /*detrec.nmovima, 0, 0, 1, NULL, NULL, NULL,
                                          v_decimals);*/
                                          detrec.nmovima, 0, 0, 1, xiprianu2, SYSDATE, NULL,
                                          v_decimals);
                                          IF v_numerr <> 0 THEN
                                             p_tab_error(f_sysdate, f_user, 'PAC_POS_CARGUE.F_GENERAR_RETORNO_POS', 1, 'ERROR F_INSDETRECIBO v_numerr: ' || v_numerr, SQLERRM);
                                          END IF;
                                          -- FIN - 08/04/2021 - Company - Ar 38674 - Inconsistencia valor recibos boton nuevo

                  IF NVL(v_numerr, 0) <> 0 THEN
                     RAISE e_error_proc;
                  END IF;
               END LOOP;

               vpas := 1280;
               v_numerr := f_vdetrecibos(pmodo, v_rec, psproces);

               IF NVL(v_numerr, 0) <> 0 THEN
                  RAISE e_error_proc;
               END IF;
            END LOOP;
         END IF;
      END LOOP;

      vpas := 1290;
        BEGIN
        DELETE FROM DETRECIBOS  WHERE NRECIBO = v_rec AND CCONCEP <> 0;
        COMMIT;
        EXCEPTION WHEN OTHERS THEN
           NULL;
        END;
      RETURN v_numerr;
   EXCEPTION
      WHEN e_error_proc THEN
         IF c_retrn%ISOPEN THEN
            CLOSE c_retrn;
         END IF;

         IF cur_recibos%ISOPEN THEN
            CLOSE cur_recibos;
         END IF;

         IF cur_detrecibos%ISOPEN THEN
            CLOSE cur_detrecibos;
         END IF;

         RETURN v_numerr;
      WHEN OTHERS THEN
         IF c_retrn%ISOPEN THEN
            CLOSE c_retrn;
         END IF;

         IF cur_recibos%ISOPEN THEN
            CLOSE cur_recibos;
         END IF;

         IF cur_detrecibos%ISOPEN THEN
            CLOSE cur_detrecibos;
         END IF;

         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 9904162;
   END f_generar_retorno_recob;  
--- FIN PYALLTIT  14/07/2020
END PAC_POS_CARGUE;