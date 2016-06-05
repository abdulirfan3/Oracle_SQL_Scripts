--
-- Perfsheetjs_query_AWR_top3_waitevent_and_CPU.sql -> Extracts data from dba_hist_system_event and dba_hist_sysstat, 
-- computes delta values and rates (delta value over delta time) and selects top 3 non-idle wait events + CPU usage for each instance
-- output is in csv format
-- Luca Canali, Oct 2012, last modified Feb 2015
--

-- Usage:
--   Run the script from sql*plus connected as a priviledged user (need to be able to read AWR tables)
--   Can run it over sql*net from client machine or locally on db server
--   Customize the file perfsheetjs_definitions.sql before running this, in particular define there the interval of analysis

@@Perfsheetjs_definitions.sql


set termout on
prompt 
prompt Dumping AWR data to file Perfsheetjs_AWR_top3_waitevent_and_CPU_&myfilesuffix..csv, please wait
prompt 
set termout off

spool Perfsheetjs_AWR_top3_waitevent_and_CPU_&myfilesuffix..csv

select cast(min(sn.begin_interval_time) over (partition by sn.dbid,sn.snap_id) as date) snap_time,  --workaround to uniform snap_time over all instances in RAC
	   sn.snap_id,
  	   sn.instance_number,
       ss.event_name,
       round((ss.time_waited_micro - lag(ss.time_waited_micro) over (partition by ss.dbid,ss.instance_number,ss.event_id order by sn.snap_id nulls first)) /
	      (extract(hour from END_INTERVAL_TIME-begin_interval_time)*3600
              -extract(hour from sn.snap_timezone - lag(sn.snap_timezone) over (partition by ss.dbid,ss.instance_number,ss.event_id order by sn.snap_id nulls first) )*3600 --deals with daylight savings time change
              + extract(minute from END_INTERVAL_TIME-begin_interval_time)* 60
              + extract(second from END_INTERVAL_TIME-begin_interval_time)),2 ) Rate_timewaited  -- time_waited_microsec/clock_time_sec summed over instances
from   dba_hist_system_event ss,
       dba_hist_snapshot sn,
       ( select ss.dbid,ss.instance_number,ss.event_id,
              rank() over (partition by ss.dbid,ss.instance_number order by max(ss.time_waited_micro)-min(ss.time_waited_micro) desc) Waited_time_rank
       from dba_hist_system_event ss,
            dba_hist_snapshot sn
       where
            sn.snap_id = ss.snap_id
            and sn.dbid = ss.dbid
            and sn.instance_number = ss.instance_number
            and sn.begin_interval_time &delta_time_where_clause
            and wait_class <>'Idle'
       group by ss.dbid,ss.instance_number,ss.event_id
       ) rw  -- this represents the ranked wait events by wait time
where
       sn.snap_id = ss.snap_id
       and sn.dbid = ss.dbid
       and sn.instance_number = ss.instance_number
       and sn.begin_interval_time &delta_time_where_clause
       and rw.dbid = ss.dbid
       and rw.instance_number = ss.instance_number
       and rw.event_id = ss.event_id
       and rw.Waited_time_rank<=3       -- top 3 wait events
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
and ss.stat_name='CPU used by this session' 
; 

spool off

