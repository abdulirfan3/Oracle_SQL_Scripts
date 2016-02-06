-- awr_genwl.sql
-- AWR CPU and IO Workload Report
-- Karl Arao, Oracle ACE (bit.ly/karlarao), OCP-DBA, RHCE
-- http://karlarao.wordpress.com
--
-- NOTE: this script is suitable for Linux/Unix only! for Windows use awr_genwl_win.sql
-- 
-- Changes: 
-- 20100201     made the feeding of dbid and instance number automatic
-- 20100201     added OS% USR,SYS,IO.. note that "OS CPU% = USR+SYS"
-- 20100201     added AAS (11th column), instance_number (3rd column)
-- 20100202     made the "Physical Memory" in MB
-- 20100203     made the output ASC for easy visualization
-- 20100511     added timestamp to filter specific workload periods, must uncomment to use
 
set arraysize 5000
set termout off;
set echo off verify off
 
COLUMN blocksize NEW_VALUE _blocksize NOPRINT
select distinct block_size blocksize from v$datafile;
 
COLUMN dbid NEW_VALUE _dbid NOPRINT
select dbid from v$database;
 
COLUMN instancenumber NEW_VALUE _instancenumber NOPRINT
select instance_number instancenumber from v$instance;
 
ttitle center 'AWR CPU and IO Workload Report' skip 2
set termout on;
set pagesize 50;
set linesize 250
 
col tm          format a15              heading "Snap|Start|Time"
col id          format 99999            heading "Snap|ID"
col inst        format 90               heading "i|n|s|t|#"
col dur         format 999990.00        heading "Snap|Dur|(m)"
col cpu         format 90               heading "C|P|U"
col cap         format 9999990.00       heading "***|Total|CPU|Time|(s)"
col dbt         format 999990.00        heading "DB|Time"
col dbc         format 99990.00         heading "DB|CPU"
col bgc         format 99990.00         heading "Bg|CPU"
col rman        format 9990.00          heading "RMAN|CPU"
col aas         format 990.0            heading "A|A|S"
col totora      format 9999990.00       heading "***|Total|Oracle|CPU|(s)"
col busy        format 9999990.00       heading "Busy|Time"
col load        format 990.00           heading "OS|Load"
col totos       format 9999990.00       heading "***|Total|OS|CPU|(s)"
col mem         format 999990.00        heading "Physical|Memory|(mb)"
col IORs        format 9990.000         heading "IOPs|r"
col IOWs        format 9990.000         heading "IOPs|w"
col IORedo      format 9990.000         heading "IOPs|redo"
col IORmbs      format 9990.000         heading "IO r|(mb)/s"
col IOWmbs      format 9990.000         heading "IO w|(mb)/s"
col redosizesec format 9990.000         heading "Redo|(mb)/s"
col logons      format 990              heading "Sess"
col logone      format 990              heading "Sess|End"
col exsraw      format 99990.000        heading "Exec|raw|delta"
col exs         format 9990.000         heading "Exec|/s"
col oracpupct   format 990              heading "Oracle|CPU|%"
col rmancpupct  format 990              heading "RMAN|CPU|%"
col oscpupct    format 990              heading "OS|CPU|%"
col oscpuusr    format 990              heading "U|S|R|%"
col oscpusys    format 990              heading "S|Y|S|%"
col oscpuio     format 990              heading "I|O|%"
 
SELECT * FROM
( 
  SELECT s0.snap_id id,
  TO_CHAR(s0.END_INTERVAL_TIME,'MM/DD/YY HH24:MI') tm,
  s0.instance_number inst,
  round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                  + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                  + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                  + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2) dur,
  s3t1.value AS cpu,
  (round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                  + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                  + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                  + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2)*60)*s3t1.value cap,
  (s5t1.value - s5t0.value) / 1000000 as dbt,
  (s6t1.value - s6t0.value) / 1000000 as dbc,
  (s7t1.value - s7t0.value) / 1000000 as bgc,
  round(DECODE(s8t1.value,null,'null',(s8t1.value - s8t0.value) / 1000000),2) as rman,
  ((s5t1.value - s5t0.value) / 1000000)/60 /  round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                  + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                  + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                  + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2) aas,
  round(((s6t1.value - s6t0.value) / 1000000) + ((s7t1.value - s7t0.value) / 1000000),2) totora,
  -- s1t1.value - s1t0.value AS busy,  -- this is osstat BUSY_TIME
  round(s2t1.value,2) AS load,
  (s1t1.value - s1t0.value)/100 AS totos,
  s4t1.value/1024/1024 AS mem, 
   ((s15t1.value - s15t0.value)  / ((round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                  + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                  + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                  + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2))*60)
    ) as IORs, 
   ((s16t1.value - s16t0.value)  / ((round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                  + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                  + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                  + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2))*60)
    ) as IOWs, 
   ((s13t1.value - s13t0.value)  / ((round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                  + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                  + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                  + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2))*60)
    ) as IORedo, 
   (((s11t1.value - s11t0.value)* &_blocksize)/1024/1024)  / ((round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                  + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                  + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                  + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2))*60) 
      as IORmbs, 
   (((s12t1.value - s12t0.value)* &_blocksize)/1024/1024)  / ((round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                  + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                  + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                  + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2))*60) 
      as IOWmbs, 
   ((s14t1.value - s14t0.value)/1024/1024)  / ((round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                  + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                  + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                  + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2))*60)
     as redosizesec, 
     s9t0.value logons, 
  -- s9t1.value logone,    -- logons end value
   ((s10t1.value - s10t0.value)  / ((round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                  + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                  + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                  + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2))*60)
    ) as exs, 
  ((round(((s6t1.value - s6t0.value) / 1000000) + ((s7t1.value - s7t0.value) / 1000000),2)) / ((round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                                                                              + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                                                                              + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                                                                              + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2)*60)*s3t1.value))*100 as oracpupct,
  ((round(DECODE(s8t1.value,null,'null',(s8t1.value - s8t0.value) / 1000000),2)) / ((round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                                                                              + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                                                                              + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                                                                              + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2)*60)*s3t1.value))*100 as rmancpupct,
  (((s1t1.value - s1t0.value)/100) / ((round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                                                                              + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                                                                              + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                                                                              + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2)*60)*s3t1.value))*100 as oscpupct,
  (((s17t1.value - s17t0.value)/100) / ((round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                                                                              + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                                                                              + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                                                                              + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2)*60)*s3t1.value))*100 as oscpuusr,
  (((s18t1.value - s18t0.value)/100) / ((round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                                                                              + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                                                                              + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                                                                              + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2)*60)*s3t1.value))*100 as oscpusys,
  (((s19t1.value - s19t0.value)/100) / ((round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                                                                              + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                                                                              + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                                                                              + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2)*60)*s3t1.value))*100 as oscpuio
FROM dba_hist_snapshot s0,
  dba_hist_snapshot s1,
  dba_hist_osstat s1t0,         -- BUSY_TIME
  dba_hist_osstat s1t1,
  dba_hist_osstat s17t0,        -- USER_TIME
  dba_hist_osstat s17t1,
  dba_hist_osstat s18t0,        -- SYS_TIME
  dba_hist_osstat s18t1,
  dba_hist_osstat s19t0,        -- IOWAIT_TIME
  dba_hist_osstat s19t1,
  dba_hist_osstat s2t1,         -- osstat just get the end value
  dba_hist_osstat s3t1,         -- osstat just get the end value
  dba_hist_osstat s4t1,         -- osstat just get the end value 
  dba_hist_sys_time_model s5t0,
  dba_hist_sys_time_model s5t1,
  dba_hist_sys_time_model s6t0,
  dba_hist_sys_time_model s6t1,
  dba_hist_sys_time_model s7t0,
  dba_hist_sys_time_model s7t1,
  dba_hist_sys_time_model s8t0,
  dba_hist_sys_time_model s8t1,
  dba_hist_sysstat s9t0,        -- logons current, sysstat absolute value should not be diffed
  dba_hist_sysstat s9t1,        
  dba_hist_sysstat s10t0,       -- execute count, diffed
  dba_hist_sysstat s10t1,
  dba_hist_sysstat s11t0,       -- physical reads, diffed
  dba_hist_sysstat s11t1,
  dba_hist_sysstat s12t0,       -- physical writes, diffed
  dba_hist_sysstat s12t1,
  dba_hist_sysstat s13t0,       -- redo writes, diffed
  dba_hist_sysstat s13t1,
  dba_hist_sysstat s14t0,       -- redo size, diffed
  dba_hist_sysstat s14t1,
  dba_hist_sysstat s15t0,       -- physical read IO requests, diffed
  dba_hist_sysstat s15t1,
  dba_hist_sysstat s16t0,       -- physical write IO requests, diffed
  dba_hist_sysstat s16t1
WHERE s0.dbid            = &_dbid    -- CHANGE THE DBID HERE!
AND s1.dbid              = s0.dbid
AND s1t0.dbid            = s0.dbid
AND s1t1.dbid            = s0.dbid
AND s2t1.dbid            = s0.dbid
AND s3t1.dbid            = s0.dbid
AND s4t1.dbid            = s0.dbid
AND s5t0.dbid            = s0.dbid
AND s5t1.dbid            = s0.dbid
AND s6t0.dbid            = s0.dbid
AND s6t1.dbid            = s0.dbid
AND s7t0.dbid            = s0.dbid
AND s7t1.dbid            = s0.dbid
AND s8t0.dbid            = s0.dbid
AND s8t1.dbid            = s0.dbid
AND s9t0.dbid            = s0.dbid
AND s9t1.dbid            = s0.dbid
AND s10t0.dbid            = s0.dbid
AND s10t1.dbid            = s0.dbid
AND s11t0.dbid            = s0.dbid
AND s11t1.dbid            = s0.dbid
AND s12t0.dbid            = s0.dbid
AND s12t1.dbid            = s0.dbid
AND s13t0.dbid            = s0.dbid
AND s13t1.dbid            = s0.dbid
AND s14t0.dbid            = s0.dbid
AND s14t1.dbid            = s0.dbid
AND s15t0.dbid            = s0.dbid
AND s15t1.dbid            = s0.dbid
AND s16t0.dbid            = s0.dbid
AND s16t1.dbid            = s0.dbid
AND s17t0.dbid            = s0.dbid
AND s17t1.dbid            = s0.dbid
AND s18t0.dbid            = s0.dbid
AND s18t1.dbid            = s0.dbid
AND s19t0.dbid            = s0.dbid
AND s19t1.dbid            = s0.dbid
AND s0.instance_number   = &_instancenumber   -- CHANGE THE INSTANCE_NUMBER HERE!
AND s1.instance_number   = s0.instance_number
AND s1t0.instance_number = s0.instance_number
AND s1t1.instance_number = s0.instance_number
AND s2t1.instance_number = s0.instance_number
AND s3t1.instance_number = s0.instance_number
AND s4t1.instance_number = s0.instance_number
AND s5t0.instance_number = s0.instance_number
AND s5t1.instance_number = s0.instance_number
AND s6t0.instance_number = s0.instance_number
AND s6t1.instance_number = s0.instance_number
AND s7t0.instance_number = s0.instance_number
AND s7t1.instance_number = s0.instance_number
AND s8t0.instance_number = s0.instance_number
AND s8t1.instance_number = s0.instance_number
AND s9t0.instance_number = s0.instance_number
AND s9t1.instance_number = s0.instance_number
AND s10t0.instance_number = s0.instance_number
AND s10t1.instance_number = s0.instance_number
AND s11t0.instance_number = s0.instance_number
AND s11t1.instance_number = s0.instance_number
AND s12t0.instance_number = s0.instance_number
AND s12t1.instance_number = s0.instance_number
AND s13t0.instance_number = s0.instance_number
AND s13t1.instance_number = s0.instance_number
AND s14t0.instance_number = s0.instance_number
AND s14t1.instance_number = s0.instance_number
AND s15t0.instance_number = s0.instance_number
AND s15t1.instance_number = s0.instance_number
AND s16t0.instance_number = s0.instance_number
AND s16t1.instance_number = s0.instance_number
AND s17t0.instance_number = s0.instance_number
AND s17t1.instance_number = s0.instance_number
AND s18t0.instance_number = s0.instance_number
AND s18t1.instance_number = s0.instance_number
AND s19t0.instance_number = s0.instance_number
AND s19t1.instance_number = s0.instance_number
AND s1.snap_id           = s0.snap_id + 1
AND s1t0.snap_id         = s0.snap_id
AND s1t1.snap_id         = s0.snap_id + 1
AND s2t1.snap_id         = s0.snap_id + 1
AND s3t1.snap_id         = s0.snap_id + 1
AND s4t1.snap_id         = s0.snap_id + 1
AND s5t0.snap_id         = s0.snap_id
AND s5t1.snap_id         = s0.snap_id + 1
AND s6t0.snap_id         = s0.snap_id
AND s6t1.snap_id         = s0.snap_id + 1
AND s7t0.snap_id         = s0.snap_id
AND s7t1.snap_id         = s0.snap_id + 1
AND s8t0.snap_id         = s0.snap_id
AND s8t1.snap_id         = s0.snap_id + 1
AND s9t0.snap_id         = s0.snap_id
AND s9t1.snap_id         = s0.snap_id + 1
AND s10t0.snap_id         = s0.snap_id
AND s10t1.snap_id         = s0.snap_id + 1
AND s11t0.snap_id         = s0.snap_id
AND s11t1.snap_id         = s0.snap_id + 1
AND s12t0.snap_id         = s0.snap_id
AND s12t1.snap_id         = s0.snap_id + 1
AND s13t0.snap_id         = s0.snap_id
AND s13t1.snap_id         = s0.snap_id + 1
AND s14t0.snap_id         = s0.snap_id
AND s14t1.snap_id         = s0.snap_id + 1
AND s15t0.snap_id         = s0.snap_id
AND s15t1.snap_id         = s0.snap_id + 1
AND s16t0.snap_id         = s0.snap_id
AND s16t1.snap_id         = s0.snap_id + 1
AND s17t0.snap_id         = s0.snap_id
AND s17t1.snap_id         = s0.snap_id + 1
AND s18t0.snap_id         = s0.snap_id
AND s18t1.snap_id         = s0.snap_id + 1
AND s19t0.snap_id         = s0.snap_id
AND s19t1.snap_id         = s0.snap_id + 1
AND s1t0.stat_name       = 'BUSY_TIME'
AND s1t1.stat_name       = s1t0.stat_name
AND s17t0.stat_name       = 'USER_TIME'
AND s17t1.stat_name       = s17t0.stat_name
AND s18t0.stat_name       = 'SYS_TIME'
AND s18t1.stat_name       = s18t0.stat_name
AND s19t0.stat_name       = 'IOWAIT_TIME'
AND s19t1.stat_name       = s19t0.stat_name
AND s2t1.stat_name       = 'LOAD'
AND s3t1.stat_name       = 'NUM_CPUS'
AND s4t1.stat_name       = 'PHYSICAL_MEMORY_BYTES'
AND s5t0.stat_name       = 'DB time'
AND s5t1.stat_name       = s5t0.stat_name
AND s6t0.stat_name       = 'DB CPU'
AND s6t1.stat_name       = s6t0.stat_name
AND s7t0.stat_name       = 'background cpu time'
AND s7t1.stat_name       = s7t0.stat_name
AND s8t0.stat_name       = 'RMAN cpu time (backup/restore)'
AND s8t1.stat_name       = s8t0.stat_name
AND s9t0.stat_name       = 'logons current'
AND s9t1.stat_name       = s9t0.stat_name
AND s10t0.stat_name       = 'execute count'
AND s10t1.stat_name       = s10t0.stat_name
AND s11t0.stat_name       = 'physical reads'
AND s11t1.stat_name       = s11t0.stat_name
AND s12t0.stat_name       = 'physical writes'
AND s12t1.stat_name       = s12t0.stat_name
AND s13t0.stat_name       = 'redo writes'
AND s13t1.stat_name       = s13t0.stat_name
AND s14t0.stat_name       = 'redo size'
AND s14t1.stat_name       = s14t0.stat_name
AND s15t0.stat_name       = 'physical read IO requests'
AND s15t1.stat_name       = s15t0.stat_name
AND s16t0.stat_name       = 'physical write IO requests'
AND s16t1.stat_name       = s16t0.stat_name
)
-- WHERE 
-- id  in (select snap_id from (select * from r2toolkit.r2_regression_data union all select * from r2toolkit.r2_outlier_data))
-- id in (336)
-- aas > 1
-- oracpupct > 50
-- oscpupct > 50
-- AND TO_CHAR(s0.END_INTERVAL_TIME,'D') >= 1     -- Day of week: 1=Sunday 7=Saturday
-- AND TO_CHAR(s0.END_INTERVAL_TIME,'D') <= 7
-- AND TO_CHAR(s0.END_INTERVAL_TIME,'HH24MI') >= 0900     -- Hour
-- AND TO_CHAR(s0.END_INTERVAL_TIME,'HH24MI') <= 1800
-- AND s0.END_INTERVAL_TIME >= TO_DATE('2010-jan-17 00:00:00','yyyy-mon-dd hh24:mi:ss')     -- Data range
-- AND s0.END_INTERVAL_TIME <= TO_DATE('2010-aug-22 23:59:59','yyyy-mon-dd hh24:mi:ss')
ORDER BY id ASC;