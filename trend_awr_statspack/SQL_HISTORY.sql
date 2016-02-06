spool hist_sql.lst
undefine sql_id
define sql_id='&sql_id'

set null null
--set lines 420
set pages 99
set trimspool on
col snap_beg format   a17
col iowait_delta            format 99999999.99 heading io|wait|delta|(ms)
col iowait_total            format 99999999.99 heading io|wait|total|(ms)
col ELAPSED_TIME_DELTA      format 99999999.99 heading elapsd|time|delta|(ms)
col CPU_TIME_DELTA          format 99999999.99 heading cpu|time|delta|(ms)
col PLAN_HASH_VALUE         heading plan_hash|value
col CONCURRENCY_WAIT_delta  format 99999999.99 heading conc|wait|delta|(ms)
col CLUSTER_WAIT_DELTA      format 99999999.99 heading clust|wait|delta|(ms)
col PX_SERVERS_EXECS_DELTA  format 99999 heading PXServ|Exec|delta
col APWAIT_DELTA            format 99999 heading appl|wait|time|delta(micro)
col PLSEXEC_TIME_DELTA      format 99999 heading plsql|exec|time|delta(micro)
col JAVAEXEC_TIME_DELTA     format 99999 heading java|exec|time|delta(micro)
col optimizer_cost        format 9999   heading opt|cost
col optimizer_mode        format a10    heading optim|mode
col kept_versions         format 999    heading kept|vers
col invalidations_delta          format 999    heading inv|alid|dlt
col parse_calls_delta     format 99999  heading parse|calls|delta
col executions_delta      format 999999 heading exec|delta
col fetches_delta         format 9999999 heading fetches|delta
col end_of_fetch_count_delta    format 99999    heading end|of|fetch|call|delta
col buffer_gets_delta           format 99999999999 heading buffer|gets|delta
col disk_reads_delta            format 9999999999   heading disk|reads|delta
col DIRECT_WRITES_DELTA         format 99999999     heading direct|writes|delta
col rows_processed_delta        format 999999999 heading rows|processed|delta
col rows_ex                     format 99999999  heading rows|exec
col snap_id                     format 99999   heading snap|id
col ela_ex                format 99999999.99 heading elapsed|per|execution
col cwt_ex                format 99999999.99 heading cwt|per|execution
col cc_ex                format 99999999.99 heading cc|per|execution
col io_ex                format 99999999.99 heading io|per|execution
col instance_number                 format 99      heading in|ID

select dba_hist_sqlstat.instance_number, sql_id, plan_hash_value,
dba_hist_sqlstat.snap_id,
to_char(dba_hist_snapshot.BEGIN_INTERVAL_TIME,'DY dd-mm hh24:mi') snap_beg,
invalidations_delta,
parse_calls_delta,
executions_delta,
px_servers_execs_delta,
fetches_delta,
buffer_gets_delta,
disk_reads_delta,
direct_writes_delta,
rows_processed_delta,
elapsed_time_delta/1000 elapsed_time_delta,
cpu_time_delta/1000 cpu_time_delta,
iowait_delta/1000 iowait_delta,
clwait_delta/1000 cluster_wait_delta,
ccwait_delta/1000 concurrency_wait_delta,
substr(optimizer_mode,1,3) opt,
case when executions_delta   = 0 then NULL
when cpu_time_delta     = 0 then NULL
else
(cpu_time_delta/executions_delta)/1000
end cpu_ex,
case when executions_delta   = 0 then NULL
when elapsed_time_delta = 0 then NULL
else
(elapsed_time_delta/executions_delta)/1000
end ela_ex
,substr(SQL_PROFILE,1,32) sql_profile
from dba_hist_sqlstat, dba_hist_snapshot
where sql_id='&&sql_id'
and dba_hist_sqlstat.snap_id=dba_hist_snapshot.snap_id
and dba_hist_sqlstat.instance_number=dba_hist_snapshot.instance_number
order by dba_hist_sqlstat.instance_number, plan_hash_value, dba_hist_sqlstat.snap_id
/

select dba_hist_sqlstat.instance_number, sql_id, plan_hash_value,
dba_hist_sqlstat.snap_id,
to_char(dba_hist_snapshot.BEGIN_INTERVAL_TIME,'DY dd-mm hh24:mi') snap_beg,
invalidations_delta,
parse_calls_delta,
executions_delta,
elapsed_time_delta/1000 elapsed_time_delta,
cpu_time_delta/1000 cpu_time_delta,
iowait_delta/1000 iowait_delta,
clwait_delta/1000 cluster_wait_delta,
ccwait_delta/1000 concurrency_wait_delta,
substr(optimizer_mode,1,3) opt,
case when executions_delta   = 0 then NULL
when rows_processed_delta = 0 then NULL
else
(rows_processed_delta/executions_delta)
end rows_ex,
case when executions_delta   = 0 then NULL
when iowait_delta = 0       then NULL
else
(iowait_delta/executions_delta)/1000
end io_ex,
case when executions_delta   = 0 then NULL
when clwait_delta = 0 then NULL
else
(clwait_delta/executions_delta)/1000
end cwt_ex,
case when executions_delta   = 0 then NULL
when ccwait_delta       = 0 then NULL
else
(ccwait_delta/executions_delta)/1000
end cc_ex,
case when executions_delta   = 0 then NULL
when cpu_time_delta     = 0 then NULL
else
(cpu_time_delta/executions_delta)/1000
end cpu_ex,
case when executions_delta   = 0 then NULL
when elapsed_time_delta = 0 then NULL
else
(elapsed_time_delta/executions_delta)/1000
end ela_ex
from dba_hist_sqlstat, dba_hist_snapshot
where sql_id='&&sql_id'
and dba_hist_sqlstat.snap_id=dba_hist_snapshot.snap_id
and dba_hist_sqlstat.instance_number=dba_hist_snapshot.instance_number
order by dba_hist_sqlstat.instance_number, plan_hash_value, dba_hist_sqlstat.snap_id
/

select plan_table_output from table (dbms_xplan.display_awr('&&sql_id',null, null, 'ADVANCED +PEEKED_BINDS'));

select plan_table_output from table (dbms_xplan.display_cursor('&&sql_id', null, 'ADVANCED +PEEKED_BINDS'));

spool off
