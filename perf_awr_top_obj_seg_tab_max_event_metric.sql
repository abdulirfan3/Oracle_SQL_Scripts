PROMPT
prompt Metric name can be from below
prompt LOGICAL_READS_DELTA, BUFFER_BUSY_WAITS_DELTA, DB_BLOCK_CHANGES_DELTA, PHYSICAL_READS_DELTA
prompt PHYSICAL_WRITES_DELTA, PHYSICAL_READS_DIRECT_DELTA, PHYSICAL_WRITES_DIRECT_DELTA
prompt ITL_WAITS_DELTA, ROW_LOCK_WAITS_DELTA, TABLE_SCANS_DELTA, CHAIN_ROW_EXCESS_DELTA
prompt
prompt For 11g+
prompt PHYSICAL_READ_REQUESTS_DELTA, PHYSICAL_WRITE_REQUESTS_DELTA, OPTIMIZED_PHYSICAL_READS_DELTA

prompt
prompt 
accept metric prompt "what to metric to look for? "
accept start_time prompt "Enter start time in format DD-MON-YYYY [HH24:MI]: "
accept end_time prompt "Enter end time in format DD-MON-YYYY [HH24:MI]: "

prompt
Prompt Top 25 objects causing &metric between &start_time - &end_time
prompt

select * from
(
select
object_name,object_type,max(&metric)
from
dba_hist_seg_stat a,
dba_hist_snapshot b,
DBA_HIST_SEG_STAT_OBJ c
where
a.snap_id=b.snap_id and
a.obj#=c.obj# and
a.ts#=c.ts# and
a.dataobj#=c.dataobj#
and b.begin_interval_time between to_date(trim('&start_time.'),'dd-mon-yyyy hh24:mi')
and to_date(trim('&end_time.'),'dd-mon-yyyy hh24:mi')
group by object_name,object_type
order by 3 desc
)
where rownum<26
/
