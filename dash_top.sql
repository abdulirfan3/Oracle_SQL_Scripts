--------------------------------------------------------------------------------
--
-- File name:   dashtop.sql
-- Purpose:     Display top ASH time (count of ASH samples) grouped by your
--              specified dimensions
--              
-- Author:      Tanel Poder
-- Copyright:   (c) http://blog.tanelpoder.com
--              
-- Usage:       
--     @dashtop <grouping_cols> <filters> <fromtime> <totime>
--
-- Example:

--@dash_top sql_id session_type='FOREGROUND' "timestamp'YYYY-MM-DD [HH24:MI:SS]'" "timestamp'YYYY-MM-DD [HH24:MI:SS]'"
--@dash_top sql_id session_type='FOREGROUND' "timestamp'2014-08-20 21:00:00'" "timestamp'2014-08-20 23:00:00'"

--@dash_top session_state,event sql_id='3rtbs9vqukc71' "timestamp'2013-10-05 01:00:00'" "timestamp'2013-10-05 03:00:00'"
--
--good for buffer busy wait   
--@ash_top session_state,event,p2text,p2,p3text,p3 sql_id='3rtbs9vqukc71' "timestamp'2013-10-05 01:00:00'" "timestamp'2013-10-05 03:00:00'"

--good for Mutext waits
--@ash_top event,top_level_call_name,sql_opname,p1text,p1 "event like 'cursor%'" "TIMESTAMP'2014-11-03 00:40:05'" "TIMESTAMP'2014-11-03 21:41:05'"

-- OTHER USES OF ASH TOP

-- @dash_top event session_type='FOREGROUND' "timestamp'2015-03-31 23:00:00'" "timestamp'2015-03-31 23:01:00'"
-- @ash_top sql_id,module "event='log file sync' and sql_id='axj4tdszmtkqp'" sysdate-('&how_many_min_back'/(24*60)) sysdate
-- @ash_top sql_id,module "sql_id='axj4tdszmtkqp'" sysdate-('&how_many_min_back'/(24*60)) sysdate
-- @dash_top sql_id module='SAPLRSSM_LOAD' "timestamp'2014-08-20 21:00:00'" "timestamp'2014-08-20 23:00:00'"
-- @dash_top sql_id "event='SQL*Net more data to client'" "timestamp'2014-08-20 21:00:00'" "timestamp'2014-08-20 23:00:00'"
-- @dash_top SQL_PLAN_LINE_ID,SQL_PLAN_OPERATION,SQL_PLAN_OPTIONS sql_id='cs0107sp43c0y' sysdate-('5'/(24*60)) sysdate
-- @dash_top sql_id session_id='3257' sysdate-('1'/(24*60)) sysdate
-- @dash_top sql_id CURRENT_OBJ#='52154' "timestamp'2014-08-20 21:00:00'" "timestamp'2014-08-20 23:00:00'"  (change curr_obj#)
-- carefull with above one as current_obj# is not correct in v$active_session_history

--
-- Other:
--     This script uses only the AWR's DBA_HIST_ACTIVE_SESS_HISTORY, use
--     @dashtop.sql for accessiong the V$ ASH view
--              
--------------------------------------------------------------------------------
COL "%This" FOR A6
--COL p1     FOR 99999999999999
--COL p2     FOR 99999999999999
--COL p3     FOR 99999999999999
COL p1text FOR A30 word_wrap
COL p2text FOR A30 word_wrap
COL p3text FOR A30 word_wrap
COL p1hex  FOR A17
COL p2hex  FOR A17
COL p3hex  FOR A17
COL event  FOR A30
COL sql_opname FOR A15
COL top_level_call_name FOR A25

/*
SELECT * FROM (
    SELECT /*+ LEADING(a) USE_HASH(u) */
/*        LPAD(ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100)||'%',5,' ') "%This"
      , &1
      , 10 * COUNT(*)                                                      "TotalSeconds"
      , 10 * SUM(CASE WHEN wait_class IS NULL           THEN 1 ELSE 0 END) "CPU"
      , 10 * SUM(CASE WHEN wait_class ='User I/O'       THEN 1 ELSE 0 END) "User I/O"
      , 10 * SUM(CASE WHEN wait_class ='Application'    THEN 1 ELSE 0 END) "Application"
      , 10 * SUM(CASE WHEN wait_class ='Concurrency'    THEN 1 ELSE 0 END) "Concurrency"
      , 10 * SUM(CASE WHEN wait_class ='Commit'         THEN 1 ELSE 0 END) "Commit"
      , 10 * SUM(CASE WHEN wait_class ='Configuration'  THEN 1 ELSE 0 END) "Configuration"
      , 10 * SUM(CASE WHEN wait_class ='Cluster'        THEN 1 ELSE 0 END) "Cluster"
      , 10 * SUM(CASE WHEN wait_class ='Idle'           THEN 1 ELSE 0 END) "Idle"
      , 10 * SUM(CASE WHEN wait_class ='Network'        THEN 1 ELSE 0 END) "Network"
      , 10 * SUM(CASE WHEN wait_class ='System I/O'     THEN 1 ELSE 0 END) "System I/O"
      , 10 * SUM(CASE WHEN wait_class ='Scheduler'      THEN 1 ELSE 0 END) "Scheduler"
      , 10 * SUM(CASE WHEN wait_class ='Administrative' THEN 1 ELSE 0 END) "Administrative"
      , 10 * SUM(CASE WHEN wait_class ='Queueing'       THEN 1 ELSE 0 END) "Queueing"
      , 10 * SUM(CASE WHEN wait_class ='Other'          THEN 1 ELSE 0 END) "Other"
   --   , TO_CHAR(MIN(sample_time), 'YYYY-MM-DD HH24:MI:SS') first_seen
   --   , TO_CHAR(MAX(sample_time), 'YYYY-MM-DD HH24:MI:SS') last_seen
    FROM
        (SELECT
             a.*
           , TO_CHAR(CASE WHEN session_state = 'ON CPU' THEN p1 ELSE null END, '0XXXXXXXXXXXXXXX') p1hex
           , TO_CHAR(CASE WHEN session_state = 'ON CPU' THEN p2 ELSE null END, '0XXXXXXXXXXXXXXX') p2hex
           , TO_CHAR(CASE WHEN session_state = 'ON CPU' THEN p3 ELSE null END, '0XXXXXXXXXXXXXXX') p3hex
        FROM dba_hist_active_sess_history a) a
      , dba_users u
    WHERE
        a.user_id = u.user_id (+)
    AND &2
    AND sample_time BETWEEN &3 AND &4
    AND snap_id IN (SELECT snap_id FROM dba_hist_snapshot WHERE sample_time BETWEEN &3 AND &4) -- for partition pruning
    GROUP BY
        &1
    ORDER BY
        "TotalSeconds" DESC
       , &1
)
WHERE
    ROWNUM <= 20
/
*/

SELECT * FROM (
    SELECT /*+ LEADING(a) USE_HASH(u) */
        LPAD(ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100)||'%',5,' ') "%This"
      , &1
      , 10 * COUNT(*)                                                      "TotalSeconds"
      , 10 * SUM(CASE WHEN wait_class IS NULL           THEN 1 ELSE 0 END) "CPU"
      , 10 * SUM(CASE WHEN wait_class ='User I/O'       THEN 1 ELSE 0 END) "User I/O"
      , 10 * SUM(CASE WHEN wait_class ='Application'    THEN 1 ELSE 0 END) "Application"
      , 10 * SUM(CASE WHEN wait_class ='Concurrency'    THEN 1 ELSE 0 END) "Concurrency"
      , 10 * SUM(CASE WHEN wait_class ='Commit'         THEN 1 ELSE 0 END) "Commit"
      , 10 * SUM(CASE WHEN wait_class ='Configuration'  THEN 1 ELSE 0 END) "Configuration"
      , 10 * SUM(CASE WHEN wait_class ='Cluster'        THEN 1 ELSE 0 END) "Cluster"
      , 10 * SUM(CASE WHEN wait_class ='Idle'           THEN 1 ELSE 0 END) "Idle"
      , 10 * SUM(CASE WHEN wait_class ='Network'        THEN 1 ELSE 0 END) "Network"
      , 10 * SUM(CASE WHEN wait_class ='System I/O'     THEN 1 ELSE 0 END) "System I/O"
      , 10 * SUM(CASE WHEN wait_class ='Scheduler'      THEN 1 ELSE 0 END) "Scheduler"
      , 10 * SUM(CASE WHEN wait_class ='Administrative' THEN 1 ELSE 0 END) "Administrative"
      , 10 * SUM(CASE WHEN wait_class ='Queueing'       THEN 1 ELSE 0 END) "Queueing"
      , 10 * SUM(CASE WHEN wait_class ='Other'          THEN 1 ELSE 0 END) "Other"
      , TO_CHAR(MIN(sample_time), 'YYYY-MM-DD HH24:MI:SS') first_seen
      , TO_CHAR(MAX(sample_time), 'YYYY-MM-DD HH24:MI:SS') last_seen
    FROM
        (SELECT
             a.*
           , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p1 ELSE null END, '0XXXXXXXXXXXXXXX') p1hex
           , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p2 ELSE null END, '0XXXXXXXXXXXXXXX') p2hex
           , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p3 ELSE null END, '0XXXXXXXXXXXXXXX') p3hex
        FROM dba_hist_active_sess_history a) a
      , dba_users u
    WHERE
        a.user_id = u.user_id (+)
    AND &2
    AND sample_time BETWEEN &3 AND &4
    AND snap_id IN (SELECT snap_id FROM dba_hist_snapshot WHERE sample_time BETWEEN &3 AND &4) -- for partition pruning
    GROUP BY
        &1
    ORDER BY
        "TotalSeconds" DESC
       , &1
)
WHERE
    ROWNUM <= 20
/