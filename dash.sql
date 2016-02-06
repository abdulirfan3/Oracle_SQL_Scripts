prompt
prompt
accept start_time prompt "Enter start time in format YYYY-MM-DD [HH24:MI:SS]: "
accept end_time prompt "Enter end time in format YYYY-MM-DD [HH24:MI:SS]: "
prompt

/*
prompt ************************************
prompt **** ASH OVERALL WAIT PROFILE
prompt ************************************
prompt RR columns are ratio to report

select * from (
select NVL(event,'CPU') event,count(*),
round((ratio_to_report(sum(1)) over ()*100),1) rr
from DBA_HIST_ACTIVE_SESS_HISTORY dash,
DBA_HIST_SNAPSHOT sn
WHERE
dash.SNAP_ID = sn.SNAP_ID
and sn.begin_interval_time between to_date(trim('&start_time.'),'yyyy-mm-dd hh24:mi:ss')
and to_date(trim('&end_time.'),'yyyy-mm-dd hh24:mi:ss')
and user_id<>0
group by event
order by 2 desc
) where rownum<11;
 
prompt ************************************
prompt **** ASH I/O by SQL_ID, Top 10
prompt ************************************
prompt RR columns are ratio to report
 
COLUMN force_matching_signature FOR 999999999999999999999999999
select * from (
select
sql_id ,sql_plan_hash_value,force_matching_signature,
NVL(event,'CPU') Event,
count(*),
round((ratio_to_report(sum(1)) over ()*100),1) rr
from DBA_HIST_ACTIVE_SESS_HISTORY dash,
DBA_HIST_SNAPSHOT sn
WHERE
dash.SNAP_ID = sn.SNAP_ID
and sn.begin_interval_time between to_date(trim('&start_time.'),'yyyy-mm-dd hh24:mi:ss')
and to_date(trim('&end_time.'),'yyyy-mm-dd hh24:mi:ss')
--and 1=1
AND wait_class LIKE '%I/O'
--AND event IS null
and user_id<>0
AND sql_id IS NOT NULL
group by
sql_id,sql_plan_hash_value,event,force_matching_signature
order by 5 desc
) where rownum<11;

prompt ************************************
prompt **** ASH DB_TIME by SQL_ID, Top 10
prompt ************************************

select * from (
select sql_id
, count(*) DBTime
, round(count(*)*100/sum(count(*))
over (), 2) pctload
from DBA_HIST_ACTIVE_SESS_HISTORY dash,
DBA_HIST_SNAPSHOT sn
WHERE
dash.SNAP_ID = sn.SNAP_ID
and sn.begin_interval_time between to_date(trim('&start_time.'),'yyyy-mm-dd hh24:mi:ss')
and to_date(trim('&end_time.'),'yyyy-mm-dd hh24:mi:ss')
and session_type <> 'BACKGROUND'
group by sql_id
order by count(*) desc
) where rownum < 11;

*/
prompt ************************************
prompt **** Wait class breakdown by sqlid/module
prompt **** Can change grouping
prompt ************************************


@dash_top sql_id session_type='FOREGROUND' "timestamp'&start_time.'" "timestamp'&end_time.'"

Prompt
prompt Run sql_wait_on_event_awr_history script to find SQLID for a paticular wait event
prompt

