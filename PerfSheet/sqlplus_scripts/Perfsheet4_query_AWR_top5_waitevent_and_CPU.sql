--
-- Perfsheet4_query_AWR_top5_waitevent_and_CPU.sql -> Extracts data from dba_hist_system_event and dba_hist_sysstat, computes delta values and rates (delta value over delta time) and selects top 5 non idle events and CPU for each instance
-- output is in csv format
-- Luca Canali, Oct 2012
--

-- Usage:
--   Run the script from sql*plus connected as a priviledged user (need to be able to read AWR tables)
--   Can run it over sql*net from client machine or locally on db server
--   Customize the file perfsheet4_definitions.sql before running this, in particular define there the interval of analysis

@@Perfsheet4_definitions.sql


set termout on
prompt 
prompt Dumping AWR data to file Perfsheet4_AWR_top5_waitevent_and_CPU_&myfilesuffix..csv, please wait
prompt 
set termout off

spool Perfsheet4_AWR_top5_waitevent_and_CPU_&myfilesuffix..csv

select snap_time, snap_id, instance_number, event_name, Rate_timewaited
from (
  select snap_time, snap_id, instance_number, event_name, Rate_timewaited,
         rank() over (partition by snap_id, instance_number order by Rate_timewaited desc) Wait_time_rank
  from (
     select cast(min(sn.begin_interval_time) over (partition by sn.dbid,sn.snap_id) as date) snap_time,  --workaround to uniform snap_time over all instances in RAC
	 sn.snap_id,
  	 sn.instance_number,
     ss.event_name,
     round((ss.time_waited_micro - lag(ss.time_waited_micro) over (partition by ss.dbid,ss.instance_number,ss.event_id order by sn.snap_id nulls first)) /
	      (extract(hour from END_INTERVAL_TIME-begin_interval_time)*3600
              -extract(hour from sn.snap_timezone - lag(sn.snap_timezone) over (partition by ss.dbid,ss.instance_number,ss.event_id order by sn.snap_id nulls first) )*3600 --deals with daylight savings time change
              + extract(minute from END_INTERVAL_TIME-begin_interval_time)* 60
              + extract(second from END_INTERVAL_TIME-begin_interval_time)),2 ) Rate_timewaited  -- time_waited_microsec/clock_time_sec summed over instances
    from dba_hist_system_event ss,
       dba_hist_snapshot sn
    where
       sn.snap_id = ss.snap_id
       and sn.dbid = ss.dbid
       and sn.instance_number = ss.instance_number
       and sn.begin_interval_time &delta_time_where_clause
       and wait_class <>'Idle'
  )
)
where Wait_time_rank<=5
      and Rate_timewaited is not null
union all  -- above is the calculation of wait events below is the calculation of CPU usage
select cast(min(sn.begin_interval_time) over (partition by sn.dbid,sn.snap_id) as date) snap_time,  --workaround to uniform snap_time over all instances in RAC
       sn.snap_id,
       sn.instance_number,
       ss.stat_name event_name,
       10000* round((ss.value - lag(ss.value) over (partition by ss.dbid,ss.instance_number,ss.stat_id order by sn.snap_id nulls first)) /
              (extract(hour from END_INTERVAL_TIME-begin_interval_time)*3600
              -extract(hour from sn.snap_timezone - lag(sn.snap_timezone) over (partition by ss.dbid,ss.instance_number,ss.stat_id order by sn.snap_id nulls first) )*3600 --deals with daylight savings time change
              + extract(minute from END_INTERVAL_TIME-begin_interval_time)* 60
              + extract(second from END_INTERVAL_TIME-begin_interval_time)),2 ) Rate_timewaited  -- rate CPU /elapsed time, converted to same units as wait events above
from dba_hist_sysstat ss,
     dba_hist_snapshot sn
where
sn.snap_id = ss.snap_id
and sn.dbid = ss.dbid
and sn.instance_number = ss.instance_number
and sn.begin_interval_time &delta_time_where_clause
and ss.stat_name='CPU used by this session'  -- I don't believe I need to add 'recursive cpu usage' and 'parse time cpu', at least not in 11gR2
; 

spool off

