--------------------------------------------------------------------------------
--
-- File name:   ashtop.sql
-- Purpose:     Display top ASH time (count of ASH samples) grouped by your
--              specified dimensions
--              
-- Author:      Tanel Poder
-- Copyright:   (c) http://blog.tanelpoder.com
--              
-- Usage:       
--     @ashtop <grouping_cols> <filters> <fromtime> <totime>
--
-- Example:
--     @ash_top username,sql_id session_type='FOREGROUND' sysdate-1/24 sysdate
--     @ash_top username,sql_id session_type='FOREGROUND' sysdate-('&how_many_min_back'/(24*60)) sysdate
--     @ash_top session_state,event sql_id='3rtbs9vqukc71' sysdate-('&how_many_min_back'/(24*60)) sysdate
--     @ash_top session_state,event sql_id='3rtbs9vqukc71' "timestamp'2013-10-05 01:00:00'" "timestamp'2013-10-05 03:00:00'"
--good for buffer busy wait   
--@ash_top session_state,event,p2text,p2,p3text,p3 sql_id='3rtbs9vqukc71' "timestamp'2013-10-05 01:00:00'" "timestamp'2013-10-05 03:00:00'"

--good for Mutext waits
--@ash_top event,top_level_call_name,sql_opname,p1text,p1 "event like 'cursor%'" "TIMESTAMP'2014-11-03 00:40:05'" "TIMESTAMP'2014-11-03 21:41:05'"
--@ash_top event,top_level_call_name,sql_opname,p1text,p1 "(event like '%mutex%' or event like '%library%')" "TIMESTAMP'2014-11-01 15:30:00'" "TIMESTAMP'2014-11-01 16:30:00'"
-- then look for SELECT * FROM v$db_object_cache WHERE hash_value = 1097020010;

-- OTHER USES OF ASH TOP

-- @ash_top event session_type='FOREGROUND' "timestamp'2015-03-31 23:00:00'" "timestamp'2015-03-31 23:01:00'"
-- @ash_top sql_id,module "event='log file sync' and sql_id='axj4tdszmtkqp'" sysdate-('&how_many_min_back'/(24*60)) sysdate
-- @ash_top sql_id,module "sql_id='axj4tdszmtkqp'" sysdate-('&how_many_min_back'/(24*60)) sysdate
-- @ash_top sql_id module='SAPLRSSM_LOAD' sysdate-('&how_many_min_back'/(24*60)) sysdate
-- @ash_top sql_id "event='SQL*Net more data to client'" sysdate-('10'/(24*60)) sysdate
-- @ash_top SQL_PLAN_LINE_ID,SQL_PLAN_OPERATION,SQL_PLAN_OPTIONS sql_id='cs0107sp43c0y' sysdate-('5'/(24*60)) sysdate
-- @ash_top sql_id session_id='3257' sysdate-('1'/(24*60)) sysdate
-- @ash_top sql_id CURRENT_OBJ#='52154' sysdate-('10'/(24*60)) sysdate  (change curr_obj#)
-- carefull with above one as current_obj# is not correct in v$active_session_history

--
-- Other:
--     This script uses only the in-memory V$ACTIVE_SESSION_HISTORY, use
--     @dashtop.sql for accessiong the DBA_HIST_ACTIVE_SESS_HISTORY archive
--              
--------------------------------------------------------------------------------
COL "%This" FOR A7
--COL p1     FOR 99999999999999
--COL p2     FOR 99999999999999
--COL p3     FOR 99999999999999
COL p1text FOR A30 word_wrap
COL p2text FOR A30 word_wrap
COL p3text FOR A30 word_wrap
COL p1hex  FOR A17
COL p2hex  FOR A17
COL p3hex  FOR A17
COL AAS    FOR 9999.9
COL totalseconds HEAD "Total|Seconds" FOR 99999999
COL event  FOR A40 WORD_WRAP

SELECT * FROM (
    SELECT /*+ LEADING(a) USE_HASH(u) */
        COUNT(*)                                                     totalseconds
      , ROUND(COUNT(*) / ((CAST(&4 AS DATE) - CAST(&3 AS DATE)) * 86400), 1) AAS
      , LPAD(ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100)||'%',5,' ') "%This"
      , &1
    , SUM(CASE WHEN wait_class IS NULL           THEN 1 ELSE 0 END) "CPU"
    , SUM(CASE WHEN wait_class ='User I/O'       THEN 1 ELSE 0 END) "User I/O"
    , SUM(CASE WHEN wait_class ='Application'    THEN 1 ELSE 0 END) "Application"
    , SUM(CASE WHEN wait_class ='Concurrency'    THEN 1 ELSE 0 END) "Concurrency"
    , SUM(CASE WHEN wait_class ='Commit'         THEN 1 ELSE 0 END) "Commit"
    , SUM(CASE WHEN wait_class ='Configuration'  THEN 1 ELSE 0 END) "Configuration"
    , SUM(CASE WHEN wait_class ='Idle'           THEN 1 ELSE 0 END) "Idle"
    , SUM(CASE WHEN wait_class ='Network'        THEN 1 ELSE 0 END) "Network"
    , SUM(CASE WHEN wait_class ='System I/O'     THEN 1 ELSE 0 END) "System I/O"
    , SUM(CASE WHEN wait_class ='Scheduler'      THEN 1 ELSE 0 END) "Scheduler"
    , SUM(CASE WHEN wait_class ='Administrative' THEN 1 ELSE 0 END) "Administrative"
    , SUM(CASE WHEN wait_class ='Cluster'        THEN 1 ELSE 0 END) "Cluster"
    , SUM(CASE WHEN wait_class ='Queueing'       THEN 1 ELSE 0 END) "Queueing"
    , SUM(CASE WHEN wait_class ='Other'          THEN 1 ELSE 0 END) "Other"
--      , TO_CHAR(MIN(sample_time), 'YYYY-MM-DD HH24:MI:SS') first_seen
--      , TO_CHAR(MAX(sample_time), 'YYYY-MM-DD HH24:MI:SS') last_seen
--      , MAX(sql_exec_id) - MIN(sql_exec_id)
--      , COUNT(DISTINCT sql_exec_start||':'||sql_exec_id)
    FROM
        (SELECT
             a.*
           , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p1 ELSE null END, '0XXXXXXXXXXXXXXX') p1hex
           , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p2 ELSE null END, '0XXXXXXXXXXXXXXX') p2hex
           , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p3 ELSE null END, '0XXXXXXXXXXXXXXX') p3hex
        FROM gv$active_session_history a) a
      , dba_users u
    WHERE
        a.user_id = u.user_id (+)
    AND &2
    AND sample_time BETWEEN &3 AND &4
    GROUP BY
        &1
    ORDER BY
        TotalSeconds DESC
       , &1
)
WHERE
    ROWNUM <= 20
/
