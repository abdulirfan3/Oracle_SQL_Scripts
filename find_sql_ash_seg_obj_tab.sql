prompt
prompt
accept start_time prompt "Enter start time in format YYYY-MM-DD [HH24:MI:SS]: "
accept end_time prompt "Enter end time in format YYYY-MM-DD [HH24:MI:SS]: "
accept sql_fulltext prompt "Enter part of sql text or tab name or view name: "
prompt

select count(*) sample_count, ash.sql_id, s.sql_text
from v$active_session_history ash, v$sql s
where ash.sample_time between to_date(trim('&start_time.'),'yyyy-mm-dd hh24:mi:ss')
and to_date(trim('&end_time.'),'yyyy-mm-dd hh24:mi:ss')
and ash.sql_id = s.sql_id
and sql_fulltext like upper(nvl('%&sql_fulltext%',sql_fulltext))
and sql_text not like 'select count(*), ash.sql_id, s.sql_text from v$active_session_history ash, v$sql s%'
group by ash.sql_id, s.sql_text
order by 1 desc;