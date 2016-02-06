
col avg_time_waited for 9.9999999
col min_time_waited for 9.9999999
col max_time_waited for 9.9999999
col sum_time_waited for 999,999,999
select * from (
select event, sql_id, count(*), 
avg(time_waited/1000000) avg_time_waited,
min(time_waited/1000000) min_time_waited,
max(time_waited/1000000) max_time_waited,
sum(time_waited/1000000) sum_time_waited
from v$active_session_history
where event like nvl('&event',event)
and sql_id like nvl('&sql_id',sql_id)
group by event, sql_id order by 7 desc)
where rownum < 100;
