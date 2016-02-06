--sql_wait_on_event_ash.sql(last 10 mins)

---- time waited and wait time in microsecond
prompt
accept start_time prompt "Enter start time in format DD-MON-YYYY [HH24:MI]: "
accept end_time prompt "Enter end time in format DD-MON-YYYY [HH24:MI]: "
accept event prompt "Enter Event name or hit enter to get all: "

Prompt 
Prompt Top 25 SQLID causing &event between &start_time - &end_time
select * from (
select event, sql_id, count(*)
from DBA_HIST_ACTIVE_SESS_HISTORY dash,
DBA_HIST_SNAPSHOT sn
where 
dash.SNAP_ID = sn.SNAP_ID
and dash.event like nvl('&event',event)
and sn.begin_interval_time between to_date(trim('&start_time.'),'dd-mon-yyyy hh24:mi')
and to_date(trim('&end_time.'),'dd-mon-yyyy hh24:mi')
group by event, sql_id
order by 3 desc)	
where rownum < 26;


Prompt Top 25 Module causing &event between &start_time - &end_time

select * from (
select module, count(*)
from DBA_HIST_ACTIVE_SESS_HISTORY dash,
DBA_HIST_SNAPSHOT sn
where 
dash.SNAP_ID = sn.SNAP_ID
and dash.event like nvl('&event',event)
and sn.begin_interval_time between to_date(trim('&start_time.'),'dd-mon-yyyy hh24:mi')
and to_date(trim('&end_time.'),'dd-mon-yyyy hh24:mi')
group by module order by 2 desc)	
where rownum < 26;

Prompt Top 25 Module and SQLID(grouped) causing &event between &start_time - &end_time

select * from (
select module,sql_id, count(*)
from DBA_HIST_ACTIVE_SESS_HISTORY dash,
DBA_HIST_SNAPSHOT sn
where 
dash.SNAP_ID = sn.SNAP_ID
and dash.event like nvl('&event',event)
and sn.begin_interval_time between to_date(trim('&start_time.'),'dd-mon-yyyy hh24:mi')
and to_date(trim('&end_time.'),'dd-mon-yyyy hh24:mi')
group by module, sql_id order by 3 desc)	
where rownum < 26;