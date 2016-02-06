set pages 9999
set long 32000
col sql_text format a40 
col execs for 999,999,999
col etime for 999,999,999.9
col avg_etime for 999,999.999
col lio for 999,999,999,999
col avg_lio for 999,999,999,999
col avg_pio for 999,999,999,999
col rows_proc for 999,999,999,999 head rows
col begin_interval_time for a30
col node for 99999
col versions for 99999
col percent_of_total for 999.99
break on report
compute sum of percent_of_total on report
select sql_id, sql_text, avg_pio, avg_lio, avg_etime, execs, rows_proc
from (
select dbms_lob.substr(sql_text,3999,1) sql_text, b.*
from dba_hist_sqltext a, (
select sql_id, sum(execs) execs, sum(etime) etime, sum(etime)/sum(execs) avg_etime, sum(pio)/sum(execs) avg_pio, 
sum(lio)/sum(execs) avg_lio, sum(rows_proc) rows_proc
from (
select ss.snap_id, ss.instance_number node, begin_interval_time, sql_id, 
nvl(executions_delta,0) execs,
elapsed_time_delta/1000000 etime,
(elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime,
buffer_gets_delta lio,
disk_reads_delta pio,
rows_processed_delta rows_proc,
(buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_lio,
(rows_processed_delta/decode(nvl(rows_processed_delta,0),0,1,executions_delta)) avg_rows,
(disk_reads_delta/decode(nvl(disk_reads_delta,0),0,1,executions_delta)) avg_pio
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where 
ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number 
and ss.snap_id between nvl('&starting_snap_id',0) and nvl('&ending_snap_id',999999999)
and executions_delta > 0
)
group by sql_id
order by 5 desc
) b
where a.sql_id = b.sql_id
and execs > 1
)
where rownum <100
and upper(sql_text) like upper(nvl('%&sql_text%',sql_text))
and sql_id like nvl('&sql_id',sql_id)
-- group by sql_id, sql_text
order by etime desc
;
set pages 50;
prompt
Prompt Look inside script to find exec time and delta values for IO
prompt 
/*
column sample_end format a21
select to_char(min(s.end_interval_time),'DD-MON-YYYY DY HH24:MI') sample_end
, q.sql_id
, q.plan_hash_value
, sum(q.EXECUTIONS_DELTA) executions
, round(sum(DISK_READS_delta)/greatest(sum(executions_delta),1),1) pio_per_exec
, round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),1) lio_per_exec
, round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),1) msec_exec
from dba_hist_sqlstat q, dba_hist_snapshot s
where q.SQL_ID=trim('&sqlid.')
and s.snap_id = q.snap_id
and s.dbid = q.dbid
and s.instance_number = q.instance_number
group by s.snap_id
, q.sql_id
, q.plan_hash_value
order by s.snap_id, q.sql_id, q.plan_hash_value;
*/



