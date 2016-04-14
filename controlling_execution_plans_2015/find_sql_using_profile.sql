break on sql_id on sql_profile on sql_text skip 1
set lines 165
col sql_profile for a30
col sql_text for a60 wrap
set verify off
set pagesize 999
col username format a13
col prog format a22
col sid format 999
col child_number format 99999 heading CHILD
col ocategory format a10
col avg_etime format 9,999,999.99
col avg_pio format 9,999,999.99
col avg_lio format 999,999,999
col etime format 9,999,999.99

select sql_id, child_number, plan_hash_value plan_hash, sql_profile, executions execs,
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime,
buffer_gets/decode(nvl(executions,0),0,1,executions) avg_lio,
sql_text
from v$sql s
where upper(sql_text) like upper(nvl('&sql_text',sql_text))
and sql_text not like '%from v$sql where sql_text like nvl(%'
and sql_id like nvl('&sql_id',sql_id)
and sql_profile is not null
order by 1, 2, 3
/
