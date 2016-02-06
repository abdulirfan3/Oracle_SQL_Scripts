-- Note that I have modified this script slightly to include snaps with 0 executions.
-- This is to account for situations with very long running statements (that generally
-- cross snapshot boundaries). In these situations, the executions_delta is incremented 
-- in the snapshot when the statement begins. There will be 0 executions_delta in
-- subsequent snapshots, but the time and lio's should still be considered.
--set lines 155
col execs for 999,999,999
col etime for 999,999,999.9
col avg_etime for 999,999.999
col avg_cpu_time for 999,999.999
col avg_lio for 999,999,999.9
col avg_pio for 9,999,999.9
col begin_interval_time for a30
col node for 99999
col plan_hash_value for 99999999999999
break on plan_hash_value on startup_time skip 1
select sql_id, plan_hash_value, 
sum(execs) execs, 
-- sum(etime) etime, 
sum(etime)/sum(execs) avg_etime, 
sum(cpu_time)/sum(execs) avg_cpu_time,
sum(lio)/sum(execs) avg_lio, 
sum(pio)/sum(execs) avg_pio
from (
select ss.snap_id, ss.instance_number node, begin_interval_time, sql_id, plan_hash_value,
nvl(executions_delta,0) execs,
elapsed_time_delta/1000000 etime,
(elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime,
buffer_gets_delta lio,
disk_reads_delta pio,
cpu_time_delta/1000000 cpu_time,
(buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_lio,
(cpu_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta)) avg_cpu_time
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where sql_id = nvl('&sql_id',sql_id)
and ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number 
-- and executions_delta > 0
)
group by sql_id, plan_hash_value
order by 5
/