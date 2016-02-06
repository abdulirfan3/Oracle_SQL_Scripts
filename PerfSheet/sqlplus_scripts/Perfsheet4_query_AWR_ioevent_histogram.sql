--
-- Perfsheet4 query to extract AWR data 
-- Perfsheet4_query_AWR_ioevent_histogram.sql -> Extracts data from dba_hist_event_histogram for io related events, computes delta values between snapshots and rates (i.e. delta values divided over delta time)

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
prompt Dumping AWR data to file Perfsheet4_AWR_ioevent_histogram_&myfilesuffix..csv, please wait
prompt 
set termout off


spool Perfsheet4_AWR_ioevent_histogram_&myfilesuffix..csv

select cast(min(sn.begin_interval_time) over (partition by sn.dbid,sn.snap_id) as date) snap_time,  --workaround to uniform snap_time over all instances in RAC
	--eh.dbid,  --uncomment if you have multiple dbid in your AWR
	sn.instance_number,
	eh.event_name,
	eh.wait_time_milli,
	--eh.wait_count,
	eh.wait_count - lag(eh.wait_count) over (partition by eh.dbid,eh.instance_number,eh.event_id,eh.wait_time_milli order by sn.snap_id nulls first) Delta_wait_count,
    round((eh.wait_count - lag(eh.wait_count) over (partition by eh.dbid,eh.instance_number,eh.event_id,eh.wait_time_milli order by sn.snap_id nulls first)) /
          (extract(hour from END_INTERVAL_TIME-begin_interval_time)*3600
              -extract(hour from sn.snap_timezone - lag(sn.snap_timezone) over (partition by eh.dbid,eh.instance_number,eh.event_id,eh.wait_time_milli order by sn.snap_id nulls first) )*3600 --deals with daylight savings time change
              + extract(minute from END_INTERVAL_TIME-begin_interval_time)* 60
              + extract(second from END_INTERVAL_TIME-begin_interval_time)),2 ) Rate_wait_count_per_bin
from dba_hist_event_histogram eh,
     dba_hist_snapshot sn
where
    sn.snap_id = eh.snap_id
and sn.dbid = eh.dbid
and sn.instance_number = eh.instance_number
and sn.begin_interval_time &delta_time_where_clause
and eh.wait_class in ('User I/O','System I/O','Commit')  -- need to limit search or dump file can grow too big
order by sn.snap_id;

spool off

