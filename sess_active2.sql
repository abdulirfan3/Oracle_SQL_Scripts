@@header

/*
*
*  Author  : Vishal Gupta
*  Purpose : Display database sessions in ACTIVE status.
*  Parameters : 1 - INST_ID       (Use % as wildcard)
*               2 - TOP_ROWCOUNT  (Default is 30)
*               3 - WHERE CLAUSE  (Default is '')
*               3 - Output Level  (Default is 'NORMAL')
*
*  Revision History:
*  ===================
*  Date       Author        Description
*  ---------  ------------  -----------------------------------------
*  08-AUG-14  Vishal Gupta  Added column to display number of parallel slaves
*  18-Dec-12  Vishal Gupta  Added output level as input
*  12-Jun-12  Vishal Gupta  Removed state column from output
*  05-Aug-04  Vishal Gupta  Created
*
*/


/************************************
*  INPUT PARAMETERS
************************************/
/*
UNDEFINE INST_ID
UNDEFINE TOP_ROWCOUNT
UNDEFINE WHERECLAUSE
UNDEFINE OUTPUT_LEVEL

DEFINE INST_ID="&&1"
DEFINE TOP_ROWCOUNT="&&2"
DEFINE WHERECLAUSE="&3"
DEFINE OUTPUT_LEVEL="&4"


set term off
COLUMN  _INST_ID          NEW_VALUE  INST_ID            NOPRINT
COLUMN  _TOP_ROWCOUNT     NEW_VALUE  TOP_ROWCOUNT       NOPRINT
COLUMN  _OUTPUT_LEVEL     NEW_VALUE  OUTPUT_LEVEL       NOPRINT
COLUMN  _WHERECLAUSE      NEW_VALUE  WHERECLAUSE        NOPRINT

SELECT DECODE('&&INST_ID','','%','&&INST_ID')            "_INST_ID"
     , DECODE('&&TOP_ROWCOUNT','','1000','&&TOP_ROWCOUNT') "_TOP_ROWCOUNT"
     , DECODE(q'[&&WHERECLAUSE]','',q'[and s.program not like '%(P%' --exclude parallel slaves]',q'[&&WHERECLAUSE]') "_WHERECLAUSE"
     , DECODE('&&OUTPUT_LEVEL','','NORMAL','&&OUTPUT_LEVEL')   "_OUTPUT_LEVEL"
FROM DUAL;
set term on


/************************************
*  CONFIGURATION PARAMETERS
************************************/
/*
set term off
COLUMN  _OUTPUT_BREIF      NEW_VALUE  OUTPUT_BREIF     NOPRINT
COLUMN  _OUTPUT_NORMAL     NEW_VALUE  OUTPUT_NORMAL    NOPRINT
COLUMN  _OUTPUT_ALL        NEW_VALUE  OUTPUT_ALL       NOPRINT
SELECT DECODE('&&OUTPUT_LEVEL','','ALL','&&OUTPUT_LEVEL')   "_OUTPUT_BREIF"
     , DECODE('&&OUTPUT_LEVEL','','ALL','&&OUTPUT_LEVEL')   "_OUTPUT_NORMAL"
     , DECODE('&&OUTPUT_LEVEL','','ALL','&&OUTPUT_LEVEL')   "_OUTPUT_ALL"
FROM DUAL;


PROMPT *************************************************************************************
PROMPT *   D A T A B A S E    S E S S I O N S   ( Top &TOP_ROWCOUNT Longest Active Sessions )  
PROMPT *   
PROMPT * Input Parameters 
PROMPT *    - Instance#     = "&&INST_ID"
PROMPT *    - Top Row Count = "&&TOP_ROWCOUNT"
PROMPT *    - Where Clause  = "&&WHERECLAUSE"
PROMPT *    - Output Level  = "&&OUTPUT_LEVEL"
PROMPT *************************************************************************************


*/
set term on

-- To hide sql, set show_sql="--"
DEFINE SHOW_SQL="--"
--DEFINE SHOW_SQL=""



COLUMN sid                        HEADING "SID"                        FORMAT 9999 
COLUMN inst_id                    HEADING "I#"                         FORMAT 99
COLUMN spid                       HEADING "SPID"                       FORMAT a6 
COLUMN status                     HEADING "Status"                     FORMAT a8
COLUMN state                      HEADING "State"                      FORMAT a12 TRUNCATED
COLUMN logon_time                 HEADING "Logon Time"                 FORMAT a18
COLUMN username                   HEADING "UserName"                   FORMAT a20
COLUMN osuser                     HEADING "OS User"                    FORMAT a15 TRUNCATED
COLUMN MACHINE                    HEADING "Machine"                    FORMAT a14 TRUNCATED
COLUMN process                    HEADING "CLIENT_PID"                  FORMAT a8 TRUNCATED
COLUMN program                    HEADING "Program"                    FORMAT a18 TRUNCATED
COLUMN sql_exec_duration          HEADING "SQL|Exec|Duration"          FORMAT a11 JUSTIFY RIGHT
COLUMN event                      HEADING "Event"                      FORMAT a30 TRUNCATED
COLUMN force_matching_signature   HEADING "Force|Matching|Signature"   FORMAT 99999999999999999999
COLUMN last_call_et               HEADING "LastCall"                   FORMAT a12  JUSTIFY RIGHT
COLUMN sql_child_number           HEADING "SQL|Child|No"               FORMAT 99
COLUMN px_slaves                  HEADING "PX|Slaves"                  FORMAT 99999
COLUMN module                     Heading "Module"                     Format a26 TRUNCATED              


--BREAK ON REPORT
--COMPUTE COUNT LABEL 'Count' OF status ON REPORT 

SELECT a.sid
     , a.inst_id
     , a.spid
     , a.status
     , a.last_call_et
     , a.machine
     , a.process
		 , a.module
&&_IF_ORA_11gR1_OR_HIGHER    , a.sql_exec_duration
     , (select count(1) from gv$px_session px where px.qcsid = a.sid and px.qcinst_id = a.inst_id and px.qcserial# = a.serial#) px_slaves
&&_IF_ORA_10gR1_OR_HIGHER    , a.sql_id
&&_IF_ORA_10gR1_OR_HIGHER    , a.sql_child_number
&&SHOW_SQL     , a.sql_text
     , a.event
		 , a.program
		 , a.username
     , a.osuser
		 , a.logon_time
FROM
(
                              SELECT s.sid
                                   , s.inst_id
                                   , s.serial#
                                   , p.spid
                                   , s.status
                                   --, s.state
                                   , to_char(s.logon_time,'DD-MON-YY HH24:MI:SS') logon_time
                                   , LPAD(DECODE(FLOOR(last_call_et / 3600),0, '', FLOOR(last_call_et / 3600) || 'h ' )
                                          || LPAD(FLOOR(MOD(last_call_et , 3600 ) / 60),2) || 'm ' 
                                          || LPAD(MOD(last_call_et, 60 ) ,2) || 's' 
                                          , 12) last_call_et
                                   , s.username
                                   , s.osuser
                                   , s.machine
                                   , s.process
                                   , s.program
																	 , s.module
   &&_IF_ORA_11gR1_OR_HIGHER       , LPAD(REPLACE(REPLACE(LPAD(FLOOR((sysdate-sql_exec_start)*24),2) || 'h ' 
   &&_IF_ORA_11gR1_OR_HIGHER                 || LPAD(FLOOR(MOD((sysdate-sql_exec_start)*24,1)*60),2) || 'm ' 
   &&_IF_ORA_11gR1_OR_HIGHER                 || LPAD(FLOOR(MOD((sysdate-sql_exec_start)*24*60,1)*60),2) || 's' 
   &&_IF_ORA_11gR1_OR_HIGHER              ,' 0h  0m ',''),' 0h ',''),11)
   &&_IF_ORA_11gR1_OR_HIGHER         sql_exec_duration 
   --&&_IF_ORA_10gR1_OR_HIGHER       , sql.force_matching_signature
   &&_IF_ORA_10gR1_OR_HIGHER       , s.sql_id
   &&_IF_ORA_10gR1_OR_HIGHER       , s.sql_child_number
                  &&SHOW_SQL       , sql.sql_text
                                   , w.event
                                FROM gv$session s
                                   , gv$session_wait   w
                                   , gv$process p
                                   , gv$sqlarea sql
                               WHERE s.type <> 'BACKGROUND'
                                 AND s.inst_id = p.inst_id
                                 AND s.paddr = p.addr
                                 AND s.inst_id = w.inst_id (+)
                                 AND s.sid     = w.sid  (+)
                                 AND s.inst_id = sql.inst_id (+)
                                 AND s.sql_id  = sql.sql_id  (+)
                                 AND s.status  <> 'INACTIVE'
                                 AND s.inst_id LIKE '%'
                                 and s.program not like '%(P%' --exclude parallel slaves  
																 and s.sid != userenv('sid') -- do not caputre my own session
                              ORDER BY GREATEST(s.last_call_et , NVL(sysdate-sql_exec_start,0) * 24 * 60 * 60 ) ASC NULLS LAST
) a
;

@@footer
