prompt
prompt enter start and end times in format DD-MON-YYYY [HH24:MI]
Prompt Get the SNAP_ID first before getting to object stats
prompt
select SNAP_ID,BEGIN_INTERVAL_TIME,END_INTERVAL_TIME from dba_hist_snapshot sn
where sn.begin_interval_time between to_date(trim('&start_time.'),'dd-mon-yyyy hh24:mi')
and to_date(trim('&end_time.'),'dd-mon-yyyy hh24:mi') order by 1;

Prompt
Prompt Enter start_snap_id, end_snap_id, username, object_name
prompt
col sample_date heading "DATE"
col sample_hour heading "HR"
col sample_day format a3 heading "Day"

select 
   to_char(BEGIN_INTERVAL_TIME, 'YYYYMMDD') sample_date, 
	 to_char(BEGIN_INTERVAL_TIME,'HH24') sample_hour, SUBSTR(to_char(BEGIN_INTERVAL_TIME,'DAY'),1,3) sample_day, 
physical_reads_total p_reads, 
physical_writes_total p_writes,
LOGICAL_READS_TOTAL logical_read,
BUFFER_BUSY_WAITS_TOTAL bb_wait,
DB_BLOCK_CHANGES_TOTAL blk_chng,
ITL_WAITS_TOTAL itl_wait,
ROW_LOCK_WAITS_TOTAL rw_lck, 
TABLE_SCANS_TOTAL tb_scn
from 
   dba_hist_seg_stat     s, 
   dba_hist_seg_stat_obj o, 
   dba_hist_snapshot     sn 
where 
   o.owner = upper('&owner') 
and 
   s.obj# = o.obj# 
and 
   sn.snap_id = s.snap_id 
and 
   object_name = upper('&obj_name')
and sn.Snap_ID  between '&start_snap_id' and '&end_snap_id'	 
order by 
   1, 2;