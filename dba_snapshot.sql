prompt
prompt ###############################################
prompt # Last 100 Snapshot ID from dba_hist_snapshot #
prompt ###############################################
prompt

col begin_interval_time format a30;
col end_interval_time format a30;
col startup_time format a30;
col flush_elapsed format a20;

select * from(
select snap_id, begin_interval_time, end_interval_time, FLUSH_ELAPSED,snap_level, startup_time 
from dba_hist_snapshot order by 2 desc
) where rownum < 101 order by 2;

prompt
prompt To create a manual AWR snapshot, run below
prompt select dbms_workload_repository.create_snapshot('ALL') from dual;
prompt