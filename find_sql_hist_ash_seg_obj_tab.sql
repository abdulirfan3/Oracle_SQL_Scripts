prompt
prompt
accept start_time prompt "Enter start time in format YYYY-MM-DD [HH24:MI:SS]: "
accept end_time prompt "Enter end time in format YYYY-MM-DD [HH24:MI:SS]: "
accept SQL_TEXT prompt "Enter part of sql text or tab name or view name: "
prompt

select count(*) SAMPLE_COUNT, dash.sql_id
from DBA_HIST_ACTIVE_SESS_HISTORY dash,
DBA_HIST_SNAPSHOT sn,
DBA_HIST_SQLTEXT dsql
WHERE
dash.SNAP_ID = sn.SNAP_ID
and sn.begin_interval_time between to_date(trim('&start_time.'),'yyyy-mm-dd hh24:mi:ss')
and to_date(trim('&end_time.'),'yyyy-mm-dd hh24:mi:ss')
and dash.sql_id = dsql.sql_id
and SQL_TEXT like upper(nvl('%&SQL_TEXT%',SQL_TEXT))
and sql_text not like 'select count(*) count, dash.sql_id from DBA_HIST_ACTIVE_SESS_HISTORY dash%'
group by dash.sql_id
order by 1 desc;