prompt
prompt
prompt enter start and end times in format DD-MON-YYYY [HH24:MI]
prompt

accept start_time prompt "Enter start time in format DD-MON-YYYY [HH24:MI]: "
accept end_time prompt "Enter end time in format DD-MON-YYYY [HH24:MI]: "
accept event prompt "Enter Event name or hit enter to get all: "


col object_name format a35;
select * from (
SELECT dbo.object_name,
dbo.object_type,
dash.event,
SUM(dash.wait_time +
dash.time_waited)*0.000001 ttl_wait_time_s
FROM DBA_HIST_ACTIVE_SESS_HISTORY dash,
DBA_HIST_SNAPSHOT sn,
dba_objects dbo
WHERE 
dash.SNAP_ID = sn.SNAP_ID
and sn.begin_interval_time between to_date(trim('&start_time.'),'dd-mon-yyyy hh24:mi')
and to_date(trim('&end_time.'),'dd-mon-yyyy hh24:mi')
AND dash.current_obj# = dbo.object_id
and dash.event like nvl('&event',event)
GROUP BY dbo.object_name, dbo.object_type, dash.event
ORDER BY 4 DESC) where rownum < 16
/


