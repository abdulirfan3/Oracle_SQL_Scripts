@@header

/*
*
*  Author     : Vishal Gupta
*  Purpose    : Generate ASH report for instances passed 
*  Parameters : 1 - Instance Number ( % for all or comma separated list of instance numbers).
*               2 - From Time ( YYYY-MM-DD HH24:MI:SS format)
*               3 - To Time ( YYYY-MM-DD HH24:MI:SS format)
*          
*
*  Revision History:
*  ===================
*  Date       Author        Description
*  ---------  ------------  -----------------------------------------
*  18-Feb-12  Vishal Gupta  Created
*  04-Oct-12  Vishal Gupta  Added default input parameter values
*/



/************************************
*  INPUT PARAMETERS
************************************/
UNDEFINE INSTANCE_LIST
UNDEFINE FROM_TIMESTAMP                   
UNDEFINE TO_TIMESTAMP

PROMPT
PROMPT ***********************************************************************
PROMPT *  A S H    R E P O R T   (HTML)
PROMPT *
PROMPT * I F   L E F T   B L A N K    T H E N    G E T    L A S T  15   M I N  
PROMPT *
PROMPT *  Input Parameters 
PROMPT *  - Instance ID  = ( % for ALL or comma separated list of instance numbers)
PROMPT *  - From Timestamp = ( YYYY-MM-DD HH24:MI:SS format)
PROMPT *  - To Timestamp   = ( YYYY-MM-DD HH24:MI:SS format)
PROMPT ***********************************************************************



DEFINE INSTANCE_LIST="&&1"
DEFINE FROM_TIMESTAMP="&&2"
DEFINE TO_TIMESTAMP="&&3"



COLUMN  _INSTANCE_LIST  NEW_VALUE INSTANCE_LIST   NOPRINT
COLUMN  _FROM_TIME      NEW_VALUE FROM_TIMESTAMP    NOPRINT
COLUMN  _TO_TIME        NEW_VALUE TO_TIMESTAMP       NOPRINT

set term off
SELECT DECODE('&&INSTANCE_LIST','','%','&&INSTANCE_LIST')  "_INSTANCE_LIST"
     , DECODE('&&FROM_TIMESTAMP','',to_char(sysdate - ('15'/(24*60)),'YYYY-MM-DD HH24:MI:SS'),'&&FROM_TIMESTAMP')  "_FROM_TIME"
     , DECODE('&&TO_TIMESTAMP','',to_char(sysdate ,'YYYY-MM-DD HH24:MI:SS'),'&&TO_TIMESTAMP')  "_TO_TIME"
FROM DUAL;
set term on


PROMPT
PROMPT ***********************************************************************
PROMPT *  A S H    R E P O R T   (HTML)
PROMPT *
PROMPT *  Input Parameters 
PROMPT *  - Instance List  = '&&INSTANCE_LIST' ( % for ALL or comma separated list of instance numbers)
PROMPT *  - From Timestamp = '&&FROM_TIMESTAMP' ( YYYY-MM-DD HH24:MI:SS format)
PROMPT *  - To Timestamp   = '&&TO_TIMESTAMP' ( YYYY-MM-DD HH24:MI:SS format)
PROMPT ***********************************************************************

set pages 0

/*

DBMS_WORKLOAD_REPOSITORY.ASH_GLOBAL_REPORT_TEXT(
   l_dbid          IN VARCHAR2(1023),
   l_inst_num      IN NUMBER,
   l_btime         IN DATE,
   l_etime         IN DATE,
   l_options       IN NUMBER    DEFAULT 0,      -- Not currently used by Oracle
   l_slot_width    IN NUMBER    DEFAULT 0,      -- Not currently used by Oracle 
   l_sid           IN NUMBER    DEFAULT NULL,   -- v$session.sid
   l_sql_id        IN VARCHAR2  DEFAULT NULL,   -- V$SQL.SQL_ID                (Wildcard allowed)
   l_wait_class    IN VARCHAR2  DEFAULT NULL,   -- v$event_name.wait_class     (Wildcard allowed)
   l_service_hash  IN NUMBER    DEFAULT NULL,   -- v$active_services.name_hash
   l_module        IN VARCHAR2  DEFAULT NULL,   -- v$session.module            (Wildcard allowed)
   l_action        IN VARCHAR2  DEFAULT NULL,   -- v$session.action            (Wildcard allowed)
   l_client_id     IN VARCHAR2  DEFAULT NULL,   -- v$session.client_identifier (Wildcard allowed)
   l_plsql_entry   IN VARCHAR2  DEFAULT NULL,
   l_data_src      IN NUMBER    DEFAULT 0)
 RETURN awrrpt_text_type_table PIPELINED;
  
*/
 
spool ash_report.html
 SELECT * from table(dbms_workload_repository.ash_global_report_html
                       (  l_dbid         => (select dbid from v$database)
                        , l_inst_num     => DECODE(upper('&INSTANCE_LIST'),'%',NULL,'&INSTANCE_LIST')
                        , l_btime        => TO_DATE('&&FROM_TIMESTAMP','YYYY-MM-DD HH24:MI:SS')
                        , l_etime        => TO_DATE('&&TO_TIMESTAMP','YYYY-MM-DD HH24:MI:SS')
                        , l_sid          => NULL
                        , l_sql_id       => NULL
                        , l_wait_class   => NULL
                        , l_service_hash => NULL
                        , l_module       => NULL
                        , l_action       => NULL
                        , l_client_id    => NULL
                       )
                   );
spool off
prompt 
PROMPT report generated as ash_report.html file.                   
                  
set pages 5000
host ash_report.html
                   
@@footer
