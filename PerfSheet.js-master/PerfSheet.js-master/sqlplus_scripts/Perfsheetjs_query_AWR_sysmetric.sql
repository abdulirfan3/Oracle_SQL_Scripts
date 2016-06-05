--
-- Perfsheetjs query to extract data in html format
-- Perfsheetjs_query_AWR_sysmetric.sql -> Extracts data from dba_hist_sysmetric_summary 
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
prompt Dumping AWR data to file Perfsheetjs_AWR_sysmetric_&myfilesuffix..csv, please wait
prompt 
set termout off

col METRIC_NAME_UNIT for a75
-- reduce white space waste by sql*plus, the calculated max length for this on 12.1.0.2 is 73

spool Perfsheetjs_AWR_sysmetric_&myfilesuffix..csv

select cast(min(sn.begin_interval_time) over (partition by sn.dbid,sn.snap_id) as date) snap_time,  --workaround to uniform snap_time over all instances in RAC
	--ss.dbid,  --uncomment if you have multiple dbid in your AWR
	sn.instance_number,
	ss.metric_name||' - '||ss.metric_unit metric_name_unit,
	ss.maxval,
	ss.average,
	ss.standard_deviation
from dba_hist_sysmetric_summary ss,
     dba_hist_snapshot sn
where
  sn.snap_id = ss.snap_id
 and sn.dbid = ss.dbid
 and sn.instance_number = ss.instance_number
 and sn.begin_interval_time &delta_time_where_clause
order by sn.snap_id;

spool off
