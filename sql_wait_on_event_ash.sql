--sql_wait_on_event_ash.sql(last 10 mins)

---- time waited and wait time in microsecond
prompt
accept how_many_min_back prompt "How many minutes do you want to go back? "
accept event prompt "Enter event name like log file sync or db file sequential read to look at  : "

Prompt 
Prompt Top 15 SQLID causing &event in last &how_many_min_back minutes
select * from (
select event, sql_id, count(*),
avg(time_waited)*0.001 avg_time_waited_ms --*0.000001 avg_time_waited_s
from gv$active_session_history ash
where ash.event like nvl('&event','%more data from%')
and ash.SAMPLE_TIME > sysdate - ('&how_many_min_back'/(24*60))
group by event, sql_id
order by 3 desc)	
where rownum < 16;


Prompt Top 15 Module causing &event in last &how_many_min_back minutes

select * from (
select module, count(*) from gv$active_session_history ash
where ash.event like nvl('&event','%more data from%') and ash.SAMPLE_TIME > sysdate - ('&how_many_min_back'/(24*60))
group by module order by 2 desc )
where rownum < 16;

Prompt Top 15 Module and SQLID(grouped) causing &event in last &how_many_min_back minutes

select * from (
select module,sql_id, count(*) from gv$active_session_history ash
where ash.event like nvl('&event','%more data from%') and ash.SAMPLE_TIME > sysdate - ('&how_many_min_back'/(24*60))
group by module,sql_id order by 3 desc )
where rownum < 16;