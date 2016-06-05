--
-- Perfsheetjs_query_AWR_sysstat.sql -> Extracts data from dba_hist_sysstat. Hundreds of system statistics provide valuable details on the workload. 
-- The query computes delta values between snapshots and rates (that is delta values divided over delta time).
-- output is in csv format
-- Luca Canali, Oct 2012
--

-- Usage:
--   Run the script from sql*plus connected as a priviledged user (need to be able to read AWR tables)
--   Can run it over sql*net from client machine or locally on db server
--   Customize the file perfsheet4_definitions.sql before running this, in particular define there the interval of analysis

@@Perfsheetjs_definitions.sql

set termout on
prompt 
prompt Dumping AWR data to file Perfsheetjs_AWR_sysstat_&myfilesuffix..csv, please wait
prompt 
set termout off

spool Perfsheetjs_AWR_sysstat_&myfilesuffix..csv

select cast(min(sn.begin_interval_time) over (partition by sn.dbid,sn.snap_id) as date) snap_time,  --workaround to uniform snap_time over all instances in RAC
	--ss.dbid,  --uncomment if you have multiple dbid in your AWR
	sn.instance_number,
	ss.stat_name,
	ss.value,
	ss.value - lag(ss.value) over (partition by ss.dbid,ss.instance_number,ss.stat_id order by sn.snap_id nulls first) Delta_value,
	extract(hour from END_INTERVAL_TIME-begin_interval_time)*3600
              -extract(hour from sn.snap_timezone - lag(sn.snap_timezone) over (partition by ss.dbid,ss.instance_number,ss.stat_id order by sn.snap_id nulls first) )*3600 --deals with daylight savings time change
              + extract(minute from END_INTERVAL_TIME-begin_interval_time)* 60
              + extract(second from END_INTERVAL_TIME-begin_interval_time) DeltaT_sec,
	round((ss.value - lag(ss.value) over (partition by ss.dbid,ss.instance_number,ss.stat_id order by sn.snap_id nulls first)) /
              (extract(hour from END_INTERVAL_TIME-begin_interval_time)*3600
              -extract(hour from sn.snap_timezone - lag(sn.snap_timezone) over (partition by ss.dbid,ss.instance_number,ss.stat_id order by sn.snap_id nulls first) )*3600 --deals with daylight savings time change
              + extract(minute from END_INTERVAL_TIME-begin_interval_time)* 60
              + extract(second from END_INTERVAL_TIME-begin_interval_time)),2 ) Rate_value
from dba_hist_sysstat ss,
     dba_hist_snapshot sn
where
sn.snap_id = ss.snap_id
and sn.dbid = ss.dbid
and sn.instance_number = ss.instance_number
and sn.begin_interval_time &delta_time_where_clause
order by sn.snap_id;

spool off

