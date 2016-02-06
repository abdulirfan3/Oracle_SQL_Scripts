
--set define off
--set pause on
prompt
accept how_many_min_back prompt "How many minutes do you want to go back? "
prompt
prompt

prompt **************************************************************************
prompt **************************************************************************
prompt
prompt   This RUNS really SLOW on 10g DB
prompt   =================================
prompt
prompt    To continue press Enter or To quit press Ctrl-C.
prompt    See inside script on how to run this on 10g 
prompt
prompt **************************************************************************
prompt **************************************************************************


pause

-- time waited and wait time in microsecond
-- Top segments

prompt
prompt When event is Blank that means its on CPU
prompt

/* -- this is same as below except its in micro seconds
   
select * from (
SELECT dba_objects.object_name,
dba_objects.object_type,
active_session_history.event,
SUM(active_session_history.wait_time +
active_session_history.time_waited) ttl_wait_time
FROM v$active_session_history active_session_history,
dba_objects
WHERE active_session_history.sample_time > sysdate - ('&how_many_min_back'/(24*60))
AND active_session_history.current_obj# = dba_objects.object_id
GROUP BY dba_objects.object_name, dba_objects.object_type, active_session_history.event
ORDER BY 4 DESC) where rownum < 16;
*/

col OBJECT_NAME format a30;
-- same as above but this is in seconds(instead of microseconds)
select * from (
SELECT dbo.object_name,
dbo.object_type,
ash.event,
SUM(ash.wait_time +
ash.time_waited)*0.000001 ttl_wait_time_s
FROM v$active_session_history ash,
dba_objects dbo
WHERE ash.sample_time > sysdate - ('&how_many_min_back'/(24*60))
AND ash.current_obj# = dbo.object_id
GROUP BY dbo.object_name, dbo.object_type, ash.event
ORDER BY 4 DESC) where rownum < 16;

/*
to run the same in 10g, run below but without rownum limitation

try to run below in toad or some GUI, as it might return lots of data

SELECT dba_objects.object_name,
dba_objects.object_type,
active_session_history.event,
SUM(active_session_history.wait_time +
active_session_history.time_waited) ttl_wait_time
FROM v$active_session_history active_session_history,
dba_objects
WHERE active_session_history.sample_time > sysdate - ('&how_many_min_back'/(24*60))
AND active_session_history.current_obj# = dba_objects.object_id
GROUP BY dba_objects.object_name, dba_objects.object_type, active_session_history.event
ORDER BY 4 DESC

*/

