----------------------------------------------------------------------------------------
--
-- File name:   unstable_plans.sql
--
-- Purpose:     Attempts to find SQL statements with plan instability.
--
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for two values, both of which can be left blank.
--
--              min_stddev: the minimum "normalized" standard deviation between plans 
--                          (the default is 2)
--
--              min_etime:  only include statements that have an avg. etime > this value
--                          (the default is .1 second)
--
-- See http://kerryosborne.oracle-guy.com/2008/10/unstable-plans/ for more info.
---------------------------------------------------------------------------------------

--set lines 155
col execs for 999,999,999
col min_etime for 999,999.99
col max_etime for 999,999.99
col avg_etime for 999,999.999
col avg_lio for 999,999,999.9
col norm_stddev for 999,999.9999
col begin_interval_time for a30
col node for 99999
break on plan_hash_value on startup_time skip 1
select * from (
select sql_id, sum(execs), min(avg_etime) min_etime, max(avg_etime) max_etime, stddev_etime/min(avg_etime) norm_stddev
from (
select sql_id, plan_hash_value, execs, avg_etime,
stddev(avg_etime) over (partition by sql_id) stddev_etime
from (
select sql_id, plan_hash_value,
sum(nvl(executions_delta,0)) execs,
(sum(elapsed_time_delta)/decode(sum(nvl(executions_delta,0)),0,1,sum(executions_delta))/1000000) avg_etime
-- sum((buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta))) avg_lio
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and executions_delta > 0
group by sql_id, plan_hash_value
)
)
group by sql_id, stddev_etime
)
where norm_stddev > nvl(to_number('&min_stddev'),2)
and max_etime > nvl(to_number('&min_etime'),.1)
order by norm_stddev
/


/*
MIN_SNAP and MAX_SNAP are the minimum/maximum snap id where the SQL statement occurs
PLAN_HASH_VALUE is the hash_value of the plan with the best elapsed time
ELA_GAIN is the estimated improvement in elapsed time by using this plan compared to the average execution time.
*/
set pages 9999 trimspool on
set numformat 999,999,999
column plan_hash_value format 99999999999999
column min_snap format 999999
column max_snap format 999999
column min_avg_ela format 999,999,999,999,999
column avg_ela format 999,999,999,999,999
column ela_gain format 999,999,999,999,999
select sql_id,
       min(min_snap_id) min_snap,
       max(max_snap_id) max_snap,
       max(decode(rw_num,1,plan_hash_value)) plan_hash_value,
       max(decode(rw_num,1,avg_ela)) min_avg_ela,
       avg(avg_ela) avg_ela,
       avg(avg_ela) - max(decode(rw_num,1,avg_ela)) ela_gain,
       -- max(decode(rw_num,1,avg_buffer_gets)) min_avg_buf_gets,
       -- avg(avg_buffer_gets) avg_buf_gets,
       max(decode(rw_num,1,sum_exec))-1 min_exec,
       avg(sum_exec)-1 avg_exec
from (
  select sql_id, plan_hash_value, avg_buffer_gets, avg_ela, sum_exec,
         row_number() over (partition by sql_id order by avg_ela) rw_num , min_snap_id, max_snap_id
  from
  (
    select sql_id, plan_hash_value , sum(BUFFER_GETS_DELTA)/(sum(executions_delta)+1) avg_buffer_gets,
    sum(elapsed_time_delta)/(sum(executions_delta)+1) avg_ela, sum(executions_delta)+1 sum_exec,
    min(snap_id) min_snap_id, max(snap_id) max_snap_id
    from dba_hist_sqlstat a
    where exists  (
       select sql_id from dba_hist_sqlstat b where a.sql_id = b.sql_id
         and  a.plan_hash_value != b.plan_hash_value
         and  b.plan_hash_value > 0)
    and plan_hash_value > 0
    group by sql_id, plan_hash_value
    order by sql_id, avg_ela
  )
  order by sql_id, avg_ela
  )
group by sql_id
having max(decode(rw_num,1,sum_exec)) > 1
order by 7 desc
/
clear columns
set numformat 9999999999

@sql_performance_changed

set lines 3000;
set pages 50;
