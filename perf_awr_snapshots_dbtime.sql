-- | PURPOSE  : Provide a list of all AWR snapshots and the total database time |
-- |            (DB Time) consumed within its interval.                         |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET PAGESIZE   50
SET TRIMSPOOL  ON
SET VERIFY     off

COLUMN instance_name_print  FORMAT a13                   HEADING 'Instance Name'
COLUMN snap_id              FORMAT 9999999               HEADING 'Snap ID'
COLUMN startup_time         FORMAT a21                   HEADING 'Instance Startup Time'
COLUMN begin_interval_time  FORMAT a20                   HEADING 'Begin Interval Time'
COLUMN end_interval_time    FORMAT a20                   HEADING 'End Interval Time'
COLUMN elapsed_time         FORMAT 999,999,999,999.99    HEADING 'Elapsed Time (min)'
COLUMN db_time              FORMAT 999,999,999,999.99    HEADING 'DB Time (min)'
COLUMN pct_db_time          FORMAT 999999999             HEADING '% DB Time'
COLUMN cpu_time             FORMAT 999,999,999.99        HEADING 'CPU Time (min)'

BREAK ON instance_name_print ON startup_time

--SPOOL awr_snapshots_dbtime.lst
/*  OLD ONE
SELECT
    i.instance_name                                                                     instance_name_print
  , s.snap_id                                                                           snap_id
  , TO_CHAR(s.startup_time, 'mm/dd/yyyy HH24:MI:SS')                                    startup_time
  , TO_CHAR(s.begin_interval_time, 'mm/dd/yyyy HH24:MI:SS')                             begin_interval_time
  , TO_CHAR(s.end_interval_time, 'mm/dd/yyyy HH24:MI:SS')                               end_interval_time
  , ROUND(EXTRACT(DAY FROM  s.end_interval_time - s.begin_interval_time) * 1440 +
          EXTRACT(HOUR FROM s.end_interval_time - s.begin_interval_time) * 60 +
          EXTRACT(MINUTE FROM s.end_interval_time - s.begin_interval_time) +
          EXTRACT(SECOND FROM s.end_interval_time - s.begin_interval_time) / 60, 2)     elapsed_time
  , ROUND((e.value - b.value)/1000000/60, 2)                                            db_time
  , ROUND(((((e.value - b.value)/1000000/60) / (EXTRACT(DAY FROM  s.end_interval_time - s.begin_interval_time) * 1440 +
                                                EXTRACT(HOUR FROM s.end_interval_time - s.begin_interval_time) * 60 +
                                                EXTRACT(MINUTE FROM s.end_interval_time - s.begin_interval_time) +
                                                EXTRACT(SECOND FROM s.end_interval_time - s.begin_interval_time) / 60) ) * 100), 2)   pct_db_time
FROM
    dba_hist_snapshot       s
  , gv$instance             i
  , dba_hist_sys_time_model e
  , dba_hist_sys_time_model b
WHERE
      i.instance_number = s.instance_number
  AND e.snap_id         = s.snap_id
  AND b.snap_id         = s.snap_id - 1
  AND e.stat_id         = b.stat_id
  AND e.instance_number = b.instance_number
  AND e.instance_number = s.instance_number
  AND e.stat_name       = 'DB time'
ORDER BY
    i.instance_name
  , s.snap_id;
*/

SELECT
    i.instance_name                                                                     instance_name_print
  , s.snap_id                                                                           snap_id
  , TO_CHAR(s.startup_time, 'mm/dd/yyyy HH24:MI:SS')                                    startup_time
  , to_char(s.begin_interval_time, 'YYYYMMDD') sample_day
  , to_char(s.begin_interval_time,'HH24')sample_hour
  , TO_CHAR(s.begin_interval_time, 'mm/dd/yyyy HH24:MI:SS')                             begin_interval_time
  , TO_CHAR(s.end_interval_time, 'mm/dd/yyyy HH24:MI:SS')                               end_interval_time
  , ROUND(EXTRACT(DAY FROM  s.end_interval_time - s.begin_interval_time) * 1440 +
          EXTRACT(HOUR FROM s.end_interval_time - s.begin_interval_time) * 60 +
          EXTRACT(MINUTE FROM s.end_interval_time - s.begin_interval_time) +
          EXTRACT(SECOND FROM s.end_interval_time - s.begin_interval_time) / 60, 2)     elapsed_time
  , ROUND((e.value - b.value)/1000000/60, 2)                                            db_time
  , ROUND(((((e.value - b.value)/1000000/60) / (EXTRACT(DAY FROM  s.end_interval_time - s.begin_interval_time) * 1440 +
                                                EXTRACT(HOUR FROM s.end_interval_time - s.begin_interval_time) * 60 +
                                                EXTRACT(MINUTE FROM s.end_interval_time - s.begin_interval_time) +
                                                EXTRACT(SECOND FROM s.end_interval_time - s.begin_interval_time) / 60) ) * 100), 2)   pct_db_time
FROM
    dba_hist_snapshot       s
  , gv$instance             i
  , dba_hist_sys_time_model e
  , dba_hist_sys_time_model b
WHERE
      i.instance_number = s.instance_number
  AND e.snap_id         = s.snap_id
  AND b.snap_id         = s.snap_id - 1
  AND e.stat_id         = b.stat_id
  AND e.instance_number = b.instance_number
  AND e.instance_number = s.instance_number
  AND e.stat_name       = 'DB time'
ORDER BY
    i.instance_name
  , s.snap_id;  

--SPOOL OFF
