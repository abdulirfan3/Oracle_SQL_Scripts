@header

/*
*
*  Author        : Vishal Gupta
*  Purpose       : Display Session Details
*  Compatibility : 10.1 and above
*  Parameters    : 1 - SID
*                  2 - INST_ID (optional, default to 1)
*
*  Revision History:
*  ===================
*  Date       Author        Description
*  ---------  ------------  --------------------------------------------------
*  05-SEP-14  Vishal Gupta  In last 10 SQL statement, removed filter for SQL_EXEC_START IS NOT NULL
*  03-JUL-14  Vishal Gupta  Change Top Session Events column formatting
                            Added PGA and Temp usage in Last 10 SQL statements section
*  20-MAY-14  Vishal Gupta  Updated last 10 sql statements query
*  12-Feb-14  Vishal Gupta  Changed session tranactions output layout to transpose
*                           columns to rows.
*  04-Oct-13  Vishal Gupta  Added SQL's SQLProfile and sql_plan_baseline
*                           information to output
*  17-May-13  Vishal Gupta  Added last 10 SQL statements from ASH
*  08-Jan-13  Vishal Gupta  Added time since last wait in wait-history section
*  05-Sep-12  Vishal Gupta  Changed output field layout again.
*  09-Aug-12  Vishal Gupta  Changed output field layout
*  11-May-12  Vishal Gupta  Change output layout. Instead of SELECT output
*                            now it display dbms_output lines.
*  27-Mar-12  Vishal Gupta  Included the session wait history
*  05-Aug-04  Vishal Gupta  Created
*
*/



/************************************
*  INPUT PARAMETERS
************************************/


VARIABLE SID number ;
VARIABLE INST_ID number ;

 BEGIN
    :SID := '&&1';
    :INST_ID := NVL('&&2',1);
    IF :INST_ID = '' OR :INST_ID IS NULL THEN
       :INST_ID := 1;
    END IF;   
END;
/

/************************************
*  CONFIGURATION PARAMETERS
************************************/
UNDEFINE TOP_EVENT_COUNT
UNDEFINE BYTES_FORMAT
UNDEFINE BYTES_HEADING
UNDEFINE BYTES_DIVIDER

DEFINE TOP_EVENT_COUNT=5

DEFINE COUNT_SMALL_FORMAT=9,999
--DEFINE COUNT_SMALL_DIVIDER="1"
--DEFINE COUNT_SMALL_HEADING="#"
DEFINE COUNT_SMALL_DIVIDER="1000"
DEFINE COUNT_SMALL_HEADING="#1000"

DEFINE COUNT_FORMAT=999,999,999,999,999
--DEFINE COUNT_DIVIDER="1"
--DEFINE COUNT_HEADING="#"
DEFINE COUNT_DIVIDER="1000"
DEFINE COUNT_HEADING="#1000"

DEFINE BYTES_FORMAT="999,999,999"
--DEFINE BYTES_DIVIDER="1024"
--DEFINE BYTES_HEADING="KB"
DEFINE BYTES_DIVIDER="1024/1024"
DEFINE BYTES_HEADING="MB"
--DEFINE BYTES_DIVIDER="1024/1024/1024"
--DEFINE BYTES_HEADING="GB"

DEFINE TIME_FORMAT=999,999
DEFINE TIME_DIVIDER="1"
DEFINE TIME_HEADING="sec"
--DEFINE TIME_DIVIDER="60"
--DEFINE TIME_HEADING="min"


COLUMN session_details1        HEADING "Session Details" FORMAT a41
COLUMN session_details2        HEADING "Session Details" FORMAT a70
COLUMN sql_details             HEADING "Session Details" FORMAT a151
COLUMN inst_id                 HEADING "I#"              FORMAT 99
COLUMN SID                     HEADING "SID"             FORMAT 99999

PROMPT
PROMPT ################# Session Details ##########################

set heading off
                    select /*+ORDERED */ 
                           /* First Column */
                              TRIM(SUBSTR('Instance           : ' || s.inst_id                 ,1,70)) || chr(10)
                           || TRIM(SUBSTR('SID                : ' || s.sid                     ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Session Serial#    : ' || s.serial#                 ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Status             : ' || s.status                  ,1,70)) || chr(10)
                           || TRIM(SUBSTR('State              : ' || s.state                   ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Logon Time         : ' || TO_CHAR(s.logon_time,'DD-MON-YY HH24:MI:SS') ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Session Duration   : ' || FLOOR(sysdate-s.logon_time)                      || 'd ' 
                                                                  || FLOOR(MOD((sysdate-s.logon_time)      ,1 ) * 24) || 'h ' 
                                                                  || FLOOR(MOD((sysdate-s.logon_time)*24   ,1 ) * 60) || 'm ' 
                                                                  || FLOOR(MOD((sysdate-s.logon_time)*24*60,1 ) * 60) || 's'
                                                                                          ,1,70))  || chr(10)
                           || TRIM(SUBSTR('LastCall(sec)      : ' || FLOOR(s.last_call_et/ 3600) || 'h ' 
                                                                  || LPAD(FLOOR(MOD(s.last_call_et , 3600 ) / 60),2) || 'm ' 
                                                                  || LPAD(MOD(s.last_call_et, 60 ) ,2) || 's'
                                                                                              ,1,70)) || chr(10) 
                           || TRIM('Failed Over        : ' || s.failed_over             ) || chr(10)
                           || TRIM('Failover Type      : ' || s.failover_type           ) || chr(10)
                           || TRIM('Failover Method    : ' || s.failover_method         ) || chr(10)
                           || TRIM('Parallel Query     : ' || s.pq_status               ) || chr(10)
                           || TRIM('PDML Enabled       : ' || s.pdml_enabled            ) || chr(10)
                           || TRIM('PDML Status        : ' || s.pdml_status             ) || chr(10)
                           || TRIM('PDDL Status        : ' || s.pddl_status             ) || chr(10)
&&_IF_ORA_10gR1_OR_HIGHER  || TRIM('SQL Trace          : ' || s.sql_trace               ) || chr(10)
&&_IF_ORA_10gR1_OR_HIGHER  || TRIM('SQL Trace Waits    : ' || s.sql_trace_waits         ) || chr(10)
&&_IF_ORA_10gR1_OR_HIGHER  || TRIM('SQL Trace Binds    : ' || s.sql_trace_binds         ) || chr(10)
&&_IF_ORA_11gR1_OR_HIGHER  || TRIM('SQL Trace PlanStats: ' || s.sql_trace_plan_stats    ) || chr(10)
                           as session_details1
                           /* Second Column */
                           ,  TRIM(SUBSTR('OS Username        : ' || s.osuser                  ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Client Machine     : ' || s.machine                 ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Client Process     : ' || s.process                 ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Program            : ' || s.program                 ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Module             : ' || s.module                  ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Action             : ' || s.action                  ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Client Info        : ' || s.client_info             ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Client Identifier  : ' || s.client_identifier       ,1,70)) || chr(10)
                           || TRIM(SUBSTR('DB UserName        : ' || s.username                ,1,70)) || chr(10)
&&_IF_ORA_10gR1_OR_HIGHER  || TRIM(SUBSTR('ServiceName        : ' || s.service_name            ,1,70)) || chr(10)
                           || TRIM(SUBSTR('DB HostName        : ' || i.host_name               ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Oracle SPID        : ' || p.spid                    ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Oracle PID         : ' || p.pid                     ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Oracle Process Name: ' || p.pname                   ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Session Type       : ' || s.type                    ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Wait Event         : ' || w.event                   ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Wait(sec)          : ' || w.seconds_in_wait         ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Wait Parameter 1   : ' || w.p1text || ' ' || w.p1   ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Wait Parameter 2   : ' || w.p2text || ' ' || w.p2   ,1,70)) || chr(10)
                           || TRIM(SUBSTR('Wait Parameter 3   : ' || w.p3text || ' ' || w.p3   ,1,70)) || chr(10)
                              as session_details2
                from  gv$session s
                    , gv$process p
                    , gv$instance i
                    , gv$session_wait w
                where s.inst_id = i.inst_id
                AND   s.inst_id = p.inst_id (+)
                AND   s.PADDR   = p.ADDR    (+)
                AND   s.inst_id = w.inst_id (+)
                AND   s.sid     = w.sid     (+)
                AND   s.sid     = :SID
                AND   s.inst_id = :INST_ID
;

PROMPT
PROMPT ################# Currrent SQL Statement ####################

-- Get the SQL Statement being executed
                select --+ 
&&_IF_ORA_11gR1_OR_HIGHER        TRIM(SUBSTR('Current  SQL Exec Start   : ' || TO_CHAR(s.sql_exec_start,'DD-MON-YY HH24:MI:SS')       ,1,150)) || chr(10) ||
                                 TRIM(SUBSTR('Current  SQL Exec Duration: ' || NVL2(s.sql_exec_start,FLOOR(sysdate - s.sql_exec_start) || 'd '
                                                                            || LPAD(FLOOR(MOD((sysdate - s.sql_exec_start) , 1) * 24 ) ,2) || 'h '
                                                                            || LPAD(FLOOR(MOD((sysdate - s.sql_exec_start) * 24 , 1) * 60 ) ,2) || 'm '
                                                                            || LPAD(FLOOR(MOD((sysdate - s.sql_exec_start) * 24 * 60 , 1) * 60 ) ,2),'')
                                                                                                  ,1,150)) || chr(10)
                             ||  TRIM(SUBSTR('Current  SQL ID           : ' || s.sql_id             ,1,150)) || chr(10)
                             ||  TRIM(SUBSTR('Current  SQL Child Number : ' || s.sql_child_number   ,1,150)) || chr(10)
                             ||  TRIM(SUBSTR('Current  SQL Plan         : ' || sql.plan_hash_value  ,1,150)) || chr(10)
                             ||  TRIM(SUBSTR('Current  SQL Profile      : ' || sql.sql_profile      ,1,150)) || chr(10)
                             ||  TRIM(SUBSTR('Current  SQL Plan Baseline: ' || sql.sql_plan_baseline,1,150)) || chr(10)
                             ||  TRIM(SUBSTR('Current  SQLText          : ' || sql.sql_text         ,1,150)) || chr(10)
                             ||  chr(10)  
&&_IF_ORA_11gR1_OR_HIGHER    ||  TRIM(SUBSTR('Previous SQL Exec Start   : ' || TO_CHAR(s.prev_exec_start,'DD-MON-YY HH24:MI:SS')       ,1,150)) || chr(10)
                             ||  TRIM(SUBSTR('Previous SQL ID           : ' || s.prev_sql_id               ,1,150)) || chr(10)  
                             ||  TRIM(SUBSTR('Previous SQL Child Number : ' || s.prev_child_number         ,1,150)) || chr(10)
                             ||  TRIM(SUBSTR('Previous SQL Plan         : ' || prev_sql.plan_hash_value    ,1,150)) || chr(10)
                             ||  TRIM(SUBSTR('Previous SQL Profile      : ' || prev_sql.sql_profile        ,1,150)) || chr(10)
                             ||  TRIM(SUBSTR('Previous SQL Plan Baseline: ' || prev_sql.sql_plan_baseline  ,1,150)) || chr(10)
                             ||  TRIM(SUBSTR('Previous SQLText          : ' || prev_sql.sql_text           ,1,150)) 
                                 as sql_details
                from  gv$session s
                    , gv$sqlarea sql
                    , gv$sqlarea prev_sql
                where s.inst_id = sql.inst_id (+)
                AND   s.sql_id  = sql.sql_id (+)
                AND   s.inst_id = prev_sql.inst_id (+)
                AND   s.prev_sql_id  = prev_sql.sql_id (+)
                AND   s.sid     = :SID
                AND   s.inst_id = :INST_ID
;


PROMPT
PROMPT ############### Session Statistics #######################

COLUMN stat               HEADING "Statisic"           FORMAT a60

WITH stat1 AS
(
   SELECT DECODE(sn.name
               ,'physical read total bytes'                  ,1
               ,'physical reads'                             ,2
               ,'physical reads direct'                      ,3
               ,'physical reads direct temporary tablespace' ,4
               ,'physical reads direct (lob)'                ,5
               ,'redo size'                                  ,6
               ,'redo size for direct writes'                ,7
               ,'CPU used by this session'                   ,8
               ,'CPU used when call started'                 ,9
               ,'session logical reads'                      ,10
               ,'user calls'                                 ,11
               , 99
                ) sr_no
         , DECODE(sn.name
               ,'physical reads'               ,RPAD('Physical Read Requests'    ,35) || ' : ' || LTRIM(TO_CHAR(ss.value,'&&COUNT_FORMAT'))
               ,'redo size'                    ,RPAD('Redo Size'                 ,35) || ' : ' || LTRIM(TO_CHAR(ROUND(ss.value/&&BYTES_DIVIDER),'&&BYTES_FORMAT')) || ' &&BYTES_HEADING'
               ,'redo size for direct writes'  ,RPAD('Redo Size (For Direct Reads)'  ,35) || ' : ' || LTRIM(TO_CHAR(ROUND(ss.value/&&BYTES_DIVIDER),'&&BYTES_FORMAT')) || ' &&BYTES_HEADING'
               ,'physical read total bytes'    ,RPAD('Physical Read Size'        ,35) || ' : ' || LTRIM(TO_CHAR(ROUND(ss.value/&&BYTES_DIVIDER),'&&BYTES_FORMAT')) || ' &&BYTES_HEADING'
               ,'CPU used when call started'   ,RPAD('CPU used when call started',35) || ' : ' || LTRIM(TO_CHAR(ROUND(ss.value/100/&&TIME_DIVIDER),'&&TIME_FORMAT')) || ' &&TIME_HEADING'
               ,'CPU used by this session'     ,RPAD('CPU used by this session'  ,35) || ' : ' || LTRIM(TO_CHAR(ROUND(ss.value/100/&&TIME_DIVIDER),'&&TIME_FORMAT')) || ' &&TIME_HEADING'
               ,'session logical reads'        ,RPAD('Logical Reads'             ,35) || ' : ' || LTRIM(TO_CHAR(ROUND((ss.value*p.value)/&&BYTES_DIVIDER),'&&BYTES_FORMAT')) || ' &&BYTES_HEADING'
               , RPAD(sn.name,35) || ' : ' || LTRIM(TO_CHAR(ss.value,'&&COUNT_FORMAT'))
                ) stat
     FROM gv$sesstat ss
        , v$statname sn
        , v$system_parameter p
    WHERE ss.statistic# = sn.statistic#
      AND sn.name IN 
       (
         'physical reads' 
        ,'redo size' 
        ,'redo size for direct writes'
        ,'physical read total bytes'
        ,'physical reads direct'
        ,'physical reads direct temporary tablespace'
        ,'physical reads direct (lob)'
        ,'user calls' 
        ,'CPU used by this session'
        ,'CPU used when call started'
        ,'session logical reads'
       )
      AND p.name = 'db_block_size'
      AND ss.inst_id = :INST_ID
      AND ss.sid     = :SID
   ORDER BY sr_no
)
, stat2 as 
(
   SELECT DECODE(sn.name
               ,'physical write total bytes'                 ,1
               ,'physical writes'                            ,2
               ,'physical writes direct'                     ,3
               ,'physical writes direct temporary tablespace',4
               ,'physical writes direct (lob)'               ,5
               ,'session pga memory'                         ,6
               ,'session pga memory max'                     ,7
               ,'OS User time used'                          ,8
               ,'OS System time used'                        ,9
               ,'bytes sent via SQL*Net to client'           ,10
               ,'bytes received via SQL*Net from client'     ,11
               , 99
                ) sr_no
         , DECODE(sn.name
               ,'physical reads'               ,RPAD('Physical Read Requests'    ,35) || ' : ' || LTRIM(TO_CHAR(ss.value,'&&COUNT_FORMAT'))
               ,'physical writes'              ,RPAD('Physical Write Requests'   ,35) || ' : ' || LTRIM(TO_CHAR(ss.value,'&&COUNT_FORMAT'))
               ,'physical read total bytes'    ,RPAD('Physical Read Size'        ,35) || ' : ' || LTRIM(TO_CHAR(ROUND(ss.value/1024/1024),'&&COUNT_FORMAT')) || ' MB'
               ,'physical write total bytes'   ,RPAD('Physical Write Size'       ,35) || ' : ' || LTRIM(TO_CHAR(ROUND(ss.value/1024/1024),'&&COUNT_FORMAT')) || ' MB'
               ,'session pga memory'           ,RPAD('PGA Memory Used (HostRAM)' ,35) || ' : ' || LTRIM(TO_CHAR(ROUND(ss.value/1024/1024),'&&COUNT_FORMAT')) || ' MB'
               ,'session pga memory max'       ,RPAD('PGA Memory Max  (HostRAM)' ,35) || ' : ' || LTRIM(TO_CHAR(ROUND(ss.value/1024/1024),'&&COUNT_FORMAT')) || ' MB'
               ,'bytes sent via SQL*Net to client'       ,RPAD('Data Sent to Client'       ,35)|| ' : ' || LTRIM(TO_CHAR(ROUND(ss.value/1024/1024),'&&COUNT_FORMAT')) || ' MB'
               ,'bytes received via SQL*Net from client' ,RPAD('Data received from Client' ,35)|| ' : ' || LTRIM(TO_CHAR(ROUND(ss.value/1024/1024),'&&COUNT_FORMAT')) || ' MB'
               , RPAD(sn.name,35) || ' : ' || LTRIM(TO_CHAR(ss.value,'&&COUNT_FORMAT'))
                ) stat
     FROM gv$sesstat ss
        , v$statname sn
    WHERE ss.statistic# = sn.statistic#
      AND sn.name IN 
       (
         'physical writes' 
        ,'physical write total bytes'
        ,'physical writes direct'
        ,'physical writes direct temporary tablespace'
        ,'physical writes direct (lob)'
        ,'session pga memory' 
        ,'session pga memory max' 
        ,'bytes sent via SQL*Net to client' 
        ,'bytes received via SQL*Net from client' 
        ,'OS User time used'
        ,'OS System time used'
       )
      AND ss.inst_id = :INST_ID
      AND ss.sid     = :SID
   ORDER BY sr_no
)
SELECT stat1.stat, stat2.stat 
  FROM stat1 
  FULL OUTER JOIN stat2 ON stat1.sr_no = stat2.sr_no 
ORDER BY stat1.sr_no  
;    


PROMPT
PROMPT ######### Session Statistics (Exadata specific) ###########

COLUMN stat               HEADING "Statistic"    FORMAT a150

WITH stat1 AS
(
   SELECT DECODE(sn.name
               ,'physical reads'                             ,1
               , 99
                ) sr_no
         , DECODE(sn.name
               ,'cell physical IO interconnect bytes'                           ,RPAD(sn.name  ,60) || ' : ' || LTRIM(TO_CHAR(ROUND(ss.value/1024/1024),'&&COUNT_FORMAT')) || ' MB'
               ,'physical read total bytes optimized'                           ,RPAD(sn.name  ,60) || ' : ' || LTRIM(TO_CHAR(ROUND(ss.value/1024/1024),'&&COUNT_FORMAT')) || ' MB'
               ,'cell physical IO bytes eligible for predicate offload'         ,RPAD(sn.name  ,60) || ' : ' || LTRIM(TO_CHAR(ROUND(ss.value/1024/1024),'&&COUNT_FORMAT')) || ' MB'
               ,'cell physical IO interconnect bytes returned by smart scan'    ,RPAD(sn.name  ,60) || ' : ' || LTRIM(TO_CHAR(ROUND(ss.value/1024/1024),'&&COUNT_FORMAT')) || ' MB'
               ,'cell physical IO bytes saved by storage index'                 ,RPAD(sn.name  ,60) || ' : ' || LTRIM(TO_CHAR(ROUND(ss.value/1024/1024),'&&COUNT_FORMAT')) || ' MB'
               ,'cell physical IO bytes eligible for predicate offload'         ,RPAD(sn.name  ,60) || ' : ' || LTRIM(TO_CHAR(ROUND(ss.value/1024/1024),'&&COUNT_FORMAT')) || ' MB'
               ,'cell IO uncompressed bytes'                                    ,RPAD(sn.name  ,60) || ' : ' || LTRIM(TO_CHAR(ROUND(ss.value/1024/1024),'&&COUNT_FORMAT')) || ' MB'
               , RPAD(sn.name,60) || ' : ' || LTRIM(TO_CHAR(ss.value,'&&COUNT_FORMAT'))
                ) stat
     FROM gv$sesstat ss
        , v$statname sn
    WHERE ss.statistic# = sn.statistic#
      AND sn.name IN 
       (
         'cell physical IO interconnect bytes'
        ,'physical read total bytes optimized'
        ,'cell physical IO bytes eligible for predicate offload'
        ,'cell physical IO interconnect bytes returned by smart scan'
        ,'cell physical IO bytes saved by storage index'
        ,'cell physical IO bytes eligible for predicate offload'
        ,'cell IO uncompressed bytes'
       )
      AND ss.inst_id = :INST_ID
      AND ss.sid     = :SID
   ORDER BY sr_no
)
SELECT stat1.stat
  FROM stat1 
ORDER BY stat1.sr_no  
;    

set heading on


PROMPT
PROMPT ################# Session Transactions ####################


COLUMN xid                      HEADING "XID"                      FORMAT a16 
COLUMN transaction_status       HEADING "Tran|Status"              FORMAT a8 
COLUMN transaction_start_date   HEADING "Tran|StartDate"           FORMAT a18 
COLUMN tran_duration            HEADING "Tran|Duration"            FORMAT a15
COLUMN space                    HEADING "Space|Tran"               FORMAT a5 
COLUMN recursive                HEADING "Recu|rsive|Tran"          FORMAT a5 
COLUMN noundo                   HEADING "No|Undo|Tran"             FORMAT a4 
COLUMN ptx                      HEADING "Par'l|Tran"               FORMAT a5 
COLUMN used_undo                HEADING "Undo|(&&BYTES_HEADING)"   FORMAT &&BYTES_FORMAT
COLUMN log_io                   HEADING "Logical|IO"               FORMAT 999,999,999
COLUMN phy_io                   HEADING "Physical|IO"              FORMAT 999,999,999
COLUMN cr_get                   HEADING "Consistent|Gets"          FORMAT 999,999,999
COLUMN name                     HEADING "Tran Name"                FORMAT a15 WRAP


set heading off

SELECT    'Transaction Name     : ' || TRIM(t.name)      || chr(10) 
       || 'XID                  : ' || TRIM(t.xid)       || chr(10)  
       || 'Parent XID           : ' || TRIM(t.ptx_xid)   || chr(10)  
       || 'Tran Status          : ' || TRIM(t.status)    || chr(10)  
       || 'Tran Start Time      : ' || TO_CHAR(t.start_date,'DD-MON-YY HH24:MI:SS')  || chr(10)  
       || 'Tran Duration        : ' || FLOOR(sysdate - t.start_date) || 'd '
                                        || LPAD(FLOOR(MOD((sysdate - t.start_date) , 1) * 24 ) ,2) || 'h '
                                        || LPAD(FLOOR(MOD((sysdate - t.start_date) * 24 , 1) * 60 ) ,2) || 'm '
                                        || LPAD(FLOOR(MOD((sysdate - t.start_date) * 24 * 60 , 1) * 60 ) ,2) || 's '  || chr(10)  
       || 'Parallel Tran        : ' || TRIM(t.ptx)       || chr(10)  
       || 'Space Tran           : ' || TRIM(t.space)     || chr(10)  
       || 'Recursive Tran       : ' || TRIM(t.recursive) || chr(10)  
       || 'No UNDO Tran         : ' || TRIM(t.noundo)    || chr(10)  
       || 'Undo                 : ' || TRIM(TO_CHAR(ROUND((t.used_ublk * p.value)/&&BYTES_DIVIDER),'&&BYTES_FORMAT')) || ' &&BYTES_HEADING' || chr(10)  
       || 'Logical IO           : ' || TRIM(TO_CHAR(t.log_io,'999,999,999'))    || chr(10)  
       || 'Physical IO          : ' || TRIM(TO_CHAR(t.phy_io,'999,999,999'))    || chr(10)  
       || 'Consistent Gets      : ' || TRIM(TO_CHAR(t.cr_get,'999,999,999'))    || chr(10)  
FROM gv$transaction t
     INNER JOIN gv$session s ON t.inst_id = s.inst_id   AND t.ses_addr = s.saddr
     INNER JOIN v$parameter p ON p.name = 'db_block_size'
WHERE s.inst_id = :INST_ID
  AND s.sid     = :SID
ORDER BY t.start_date
;

set heading on

PROMPT
PROMPT ######### Locked Objects ##########################

COLUMN object_name  HEADING "ObjectName"   FORMAT a40
COLUMN object_type  HEADING "ObjectType"   FORMAT a10 TRUNCATED
COLUMN locked_mode  HEADING "LockedMode"   FORMAT a10 

SELECT o.owner || '.' || o.object_name object_name
     , o.object_type
     , DECODE(l.locked_mode,
              0, 'None',           /* Mon Lock equivalent */
              1, 'Null',           /* N */
              2, 'Row-S (SS)',     /* L */
              3, 'Row-X (SX)',     /* R */
              4, 'Share',          /* S */
              5, 'S/Row-X (SSX)',  /* C */
              6, 'Exclusive',      /* X */
              TO_CHAR(l.locked_mode)) locked_mode
  FROM gv$locked_object l
       JOIN dba_objects o ON o.object_id = l.object_id
       JOIN gv$session s ON s.inst_id = l.inst_id AND s.sid = l.session_id
WHERE  s.sid = :SID
  AND  s.inst_id = :INST_ID
ORDER BY object_name
;



               
PROMPT
PROMPT ######### Session Lock Information #################

COLUMN Block                            HEADING "Block"                      FORMAT a10
COLUMN blocking_instance                HEADING "Blocking|I#"                FORMAT 999999999
COLUMN blocking_instance                HEADING "Blocking|I#"                FORMAT 999999999
COLUMN blocking_session_status          HEADING "Blocking|SID Status"        FORMAT a10
COLUMN final_blocking_instance          HEADING "Final|Blocking|I#"          FORMAT 999999999
COLUMN final_blocking_session           HEADING "Final|Blocking|SID"         FORMAT 999999999
COLUMN final_blocking_session_status    HEADING "Final|Blocking|SID Status"  FORMAT a10
COLUMN inst_id                          HEADING "I#"                         FORMAT 99
COLUMN username                         HEADING "DBUser"                     FORMAT a15
COLUMN osuser                           HEADING "OSUser"                     FORMAT a15
COLUMN status                           HEADING "Status"                     FORMAT a10
COLUMN state                            HEADING "State"                      FORMAT a10
COLUMN logon_time                       HEADING "LogonTime"                  FORMAT a18
COLUMN service_name                     HEADING "ServiceName"                FORMAT a20


                       select 'Blocked By' Block
&&_IF_ORA_10gR2_OR_HIGHER     , s.blocking_instance
                              , s.blocking_session
                              , s.blocking_session_status
&&_IF_ORA_11gR2_OR_HIGHER     , s.final_blocking_instance
&&_IF_ORA_11gR2_OR_HIGHER     , s.final_blocking_session
&&_IF_ORA_11gR2_OR_HIGHER     , s.final_blocking_session_status
                         FROM gv$session s
                        where s.sid = :SID
                        AND   s.inst_id = :INST_ID
                        and s.blocking_session is NOT NULL
                        order by 1;


select 'Blocking' Block
     , s.inst_id
     , s.SID
     --, s.SERIAL#
     , s.username
     , s.osuser
     , s.status
     , s.state
     , CASE
          WHEN s.status = 'ACTIVE' THEN s.last_call_et
          ELSE NULL
       END last_call_et
     , TO_CHAR(s.LOGON_TIME,'DD-Mon-YY HH24:MI:SS') logon_time
     , s.service_name
  , s.sql_id
FROM gv$session s
where (s.blocking_session = :SID  
       AND s.blocking_instance = :INST_ID)
   OR (s.final_blocking_session = :SID  
       AND s.final_blocking_instance = :INST_ID)   
;


PROMPT
PROMPT ######### Session Events (Top &&TOP_EVENT_COUNT) ###

COLUMN wait_class      HEAD "WaitClass"          FORMAT a20 TRUNCATE
COLUMN event           HEAD "EventName"          FORMAT a40
COLUMN total_waits     HEAD "TotalWaits"         FORMAT 9,999,999
COLUMN total_timeouts  HEAD "TotalTimeOuts"      FORMAT 9,999,999
COLUMN time_waited     HEAD "TimeWaited (s)"     FORMAT 9,999,999
COLUMN average_wait    HEAD "AvgWait (s)"        FORMAT 9,999,999
COLUMN max_wait        HEAD "MaxWait (s)"        FORMAT 9,999,999

select * from 
(
SELECT e.inst_id
     , e.sid
     , e.wait_class
     , e.event
     , e.total_waits
     , e.total_timeouts
     , e.time_waited / 100 time_waited
     , e.average_wait / 100 average_wait
     , e.max_wait    / 100 max_wait
FROM   gv$session_event e
WHERE  e.sid  = :SID
AND    e.inst_id = :INST_ID
order by e.time_waited desc
)
where rownum <= &&TOP_EVENT_COUNT
/


PROMPT
PROMPT ######### Session Wait History #####################

COLUMN seq#                                                   FORMAT 999
COLUMN state                                                  FORMAT a10
COLUMN event                 HEADING "EventName"              FORMAT a40
COLUMN wait_time             HEADING "Wait(ms)"               FORMAT 99,999        
COLUMN TIME_SINCE_LAST_WAIT  HEADING "TimeSince|LastWait|(ms)"  FORMAT 99,999        
COLUMN p1                                                     FORMAT 9999999999
COLUMN p2                                                     FORMAT 9999999999
COLUMN p3                                                     FORMAT 9999999999
COLUMN p1text                                                 FORMAT a20 
COLUMN p2text                                                 FORMAT a20 
COLUMN p3text                                                 FORMAT a20 

SELECT w.inst_id
     , w.sid
     , w.seq#
     , w.event
     , w.wait_time * 10 wait_time
     , w.TIME_SINCE_LAST_WAIT_MICRO/1000 TIME_SINCE_LAST_WAIT
     , w.p1
     , w.p1text
     , w.p2
     , w.p2text
     , w.p3
     , w.p3text
FROM   gv$session_wait_history w
WHERE  w.sid  = :SID
AND    w.inst_id = :INST_ID
ORDER BY seq#
/


PROMPT
PROMPT ######### Last 10 SQL Statements ##################

COLUMN session_id                 HEADING "SID"              FORMAT 99999
COLUMN inst_id                    HEADING "I#"               FORMAT 99
COLUMN "session_serial#"          HEADING "Serial#"          FORMAT 999999
COLUMN FORCE_MATCHING_SIGNATURE                              FORMAT 99999999999999999999999
COLUMN sql_plan_hash_value        HEADING "Plan|Hash|Value"  FORMAT 9999999999 
COLUMN sql_exec_start                                        FORMAT a19
COLUMN sql_exec_end               HEADING "MaxSampleTime"    FORMAT a19
COLUMN duration                                              FORMAT a15
COLUMN sql_opname                 HEADING "SQL|Operation"    FORMAT a15 TRUNCATE
COLUMN sql_child_number           HEADING "SQL|Ch#"          FORMAT 999
COLUMN current_dop                HEADING "DOP"              FORMAT 999
COLUMN pga_allocated              HEADING "PGA|(GB)"                  FORMAT 99.00
COLUMN temp_space_allocated       HEADING "Temp|Space|(GB)"           FORMAT 999.00

-- Get the SQL Statements from ASH
SELECT * FROM 
(
SELECT --ash.sql_exec_id,
       --TO_CHAR(NVL(ash.sql_exec_start,MIN(ash.sample_time)),'DD-MON-YY HH24:MI:SS') sql_exec_start
          NVL(ash.qc_session_id,ash.session_id)                                        session_id 
     , NVL(ash.qc_instance_id,ash.inst_id)                                          inst_id     
     , NVL(ash.qc_session_serial#,ash.session_serial#)                              session_serial#
     , TO_CHAR(NVL(ash.sql_exec_start,MIN(ash.sample_time)),'DD-MON-YY HH24:MI:SS') sql_exec_start
     , TO_CHAR(max(ash.sample_time) ,'DD-MON-YY HH24:MI:SS')                    sql_exec_end
     , REPLACE(max(ash.sample_time) - NVL(ash.sql_exec_start,MIN(ash.sample_time)),'+00000000','+')          duration
&&_IF_ORA_11gR2_OR_HIGHER     , ash.sql_opname
     , ash.sql_id
     , ash.sql_child_number
     , ash.sql_plan_hash_value
&&_IF_ORA_11202_OR_HIGHER , max(trunc(ash.px_flags / 2097152)) current_dop
     , ash.force_matching_signature
     , NVL(ash_parent.top_level_sql_id,ash.top_level_sql_id) top_level_sql_id
     , ROUND(MAX(ash.pga_allocated)/power(1024,3),2)              pga_allocated
     , ROUND(MAX(ash.temp_space_allocated)/power(1024,3),2)       temp_space_allocated
  FROM gv$session s
       JOIN gv$active_session_history ash 
                    ON s.inst_id = NVL(ash.qc_instance_id,ash.inst_id)
                   AND s.sid     = NVL(ash.qc_session_id,ash.session_id)
                   AND s.serial# = NVL(ash.qc_session_serial#,ash.session_serial#)
       LEFT OUTER JOIN gv$active_session_history ash_parent
                    ON ash_parent.inst_id                   = ash.qc_instance_id
                   AND ash_parent.session_id                = ash.qc_session_id
                   AND ash_parent.session_serial#           = ash.qc_session_serial#
                   AND CAST(ash_parent.sample_time as DATE) = ash.sql_exec_start
 WHERE s.inst_id    = :INST_ID
   AND s.sid        = :SID
   --AND ash.sql_exec_id IS NOT NULL
GROUP BY NVL(ash.qc_session_id,ash.session_id)
       , NVL(ash.qc_instance_id,ash.inst_id)   
       , NVL(ash.qc_session_serial#,ash.session_serial#)
       , ash.sql_exec_id
       , ash.sql_exec_start
       , ash.sql_id
       , ash.sql_child_number
       , ash.sql_plan_hash_value
       , ash.FORCE_MATCHING_SIGNATURE
&&_IF_ORA_11gR2_OR_HIGHER       , ash.sql_opname
       , NVL(ash_parent.top_level_sql_id,ash.top_level_sql_id)
ORDER BY 
        -- max(ash.sample_time) asc
       --, 
       NVL(ash.sql_exec_start,MIN(ash.sample_time)) DESC   
     , max(ash.sample_time) DESC
)       
WHERE ROWNUM <= 10
ORDER BY sql_exec_end
;


PROMPT
PROMPT ######### Kill/Disconnect Command ##################

COLUMN command           HEADING "Disconnect Command"   FORMAT a60
COLUMN command2          HEADING "Kill Command"         FORMAT a60

BEGIN
  FOR i IN (select 'alter system disconnect session '''  || s.sid || ',' || s.serial# || ',@' || s.inst_id || ''' immediate ; ' Command
            , 'alter system kill session '''  || s.sid || ',' || s.serial# || ',@' || s.inst_id || ''' immediate ; '       Command2
            from  gv$session s
                , gv$process p
            where s.inst_id = p.inst_id (+)
              AND   s.PADDR = p.ADDR (+)
              AND   s.sid = :SID
              AND   s.inst_id = :INST_ID)
  LOOP
     DBMS_OUTPUT.PUT_LINE(   i.command || chr(10)
                       || i.command2 );
  END LOOP;  
END;
/


@@footer
