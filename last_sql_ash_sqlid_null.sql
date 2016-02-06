--https://coskan.wordpress.com/2011/11/11/where-is-the-sql_id-of-active-session/

prompt 
Prompt This is ASH SAMPLE.  May NOT be accurate, as session needs to be active to get sampled
prompt

select *from (
select inst_id,sample_time,session_id,session_serial#,SQL_EXEC_ID,sql_id from
gv$active_session_history
where
sql_id is not null
 and session_id='&SID' and inst_id=1
 order by 1 desc
) where rownum < 51;

Prompt
Prompt Can get similar info from V$OPEN_CURSOR or V$SQL_PLAN_MONITOR, look inside script
Prompt
-- Can also look at v$open_cursor to get similar info
/*
-- 99.9% it works if the sql was running long enough to get monitored and then lost the track

select distinct inst_id,sid,status,sql_id,sql_plan_hash_value,sql_child_address,sql_exec_id
 from gv$sql_plan_monitor
 where sid='&SID' and status='EXECUTING';
 */
 
