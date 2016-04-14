----------------------------------------------------------------------------------------
--
-- File name:   as.sql (Active Sessions)
--
-- Purpose:     Show Active SQL statements (except this one).
--
-- Author:      Kerry Osborne
--
--              See kerryosborne.oracle-guy.com for additional information.
---------------------------------------------------------------------------------------
col username format a13
col prog format a10 trunc
col sql_text format a51 trunc
col sid format 9999
col plan_hash_value format 999999999999
col child for 99999
col execs format 999,999,999
col avg_etime format 99,999.9999
col avg_pio format 9,999,999.9
col avg_lio format 99,999,999,999
break on sql_text skip 1
select /* as.sql */ sid, substr(program,1,19) prog, b.sql_id, sql_child_number child, plan_hash_value, executions execs, 
disk_reads/decode(nvl(executions,0),0,1,executions) avg_pio,
buffer_gets/decode(nvl(executions,0),0,1,executions) avg_lio,
(elapsed_time/decode(nvl(executions,0),0,1,executions))/1000000 avg_etime, 
sql_text
from v$session a, v$sql b
where status = 'ACTIVE'
and username is not null
and a.sql_id = b.sql_id
and a.sql_child_number = b.child_number
-- and audsid != SYS_CONTEXT('userenv','sessionid')
and sql_text not like 'select /* as.sql */ sid, substr(program,1,19) prog, b.sql_id, sql_child_number child, plan_hash_value, ex%'
order by sql_id, sql_child_number
/

