/*
Enter value for sql_text:
Enter value for address:
Enter value for sql_id: 9qst8n375p2gs
*/
set verify off
set pagesize 999
col username format a13
col prog format a22
col sql_text format a41
col sid format 999
col child_number format 99999 heading CHILD
col ocategory format a10
col avg_etime format 9,999,999.99
col etime format 9,999,999.99
col EXACT_MATCHING_SIGNATURE format 999999999999999999999999999999
col FORCE_MATCHING_SIGNATURE format 999999999999999999999999999999


prompt
Prompt +--------------------------------+
Prompt + Enter sql_text% or/and sql_id  +
Prompt +--------------------------------+
prompt

/*  VERSION 1

select sql_id, child_number, plan_hash_value plan_hash, HASH_VALUE, executions execs, elapsed_time/1000000 etime,
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime, u.username,
cpu_time/1000 cpu_ms,
--11g PHYSICAL_READ_BYTES/1024/1024/1024 PHYSICAL_READ_GB,
--11g     PHYSICAL_READ_BYTES/1024/1024/decode(nvl(executions,0),0,1,executions) PIO_MB_PE,
     buffer_gets/decode(nvl(executions,0),0,1,executions) LIOS_PE,
     disk_reads/decode(nvl(executions,0),0,1,executions) PIOS_PE,USERS_EXECUTING,
sql_text,LAST_ACTIVE_TIME, LAST_LOAD_TIME,EXACT_MATCHING_SIGNATURE,FORCE_MATCHING_SIGNATURE
from v$sql s, dba_users u
where upper(sql_fulltext) like upper(nvl('%&sql_fulltext',sql_fulltext))
and sql_text not like '%from v$sql where sql_fulltext like nvl(%'
and sql_id like nvl('&sql_id',sql_id)
and u.user_id = s.parsing_user_id
/
*/

-- in use VERSION 2(if things dont work, revert back to version 1)
select sql_id, child_number, plan_hash_value plan_hash, HASH_VALUE, executions execs, elapsed_time/1000000 etime,
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime, u.username,
cpu_time/1000 cpu_ms,
--11g PHYSICAL_READ_BYTES/1024/1024/1024 PHYSICAL_READ_GB,
--11g     PHYSICAL_READ_BYTES/1024/1024/decode(nvl(executions,0),0,1,executions) PIO_MB_PE,
     buffer_gets/decode(nvl(executions,0),0,1,executions) LIOS_PE,
     disk_reads/decode(nvl(executions,0),0,1,executions) PIOS_PE,USERS_EXECUTING,
sql_text,LAST_ACTIVE_TIME, LAST_LOAD_TIME,EXACT_MATCHING_SIGNATURE,FORCE_MATCHING_SIGNATURE
from v$sql s, dba_users u
where upper(sql_fulltext) like upper(nvl('%&sql_fulltext',sql_fulltext))
and upper(sql_fulltext) not like 'EXPLAIN PLAN%' and sql_text not like 'select sql_id, child_number, plan_hash_value plan_hash%'
and sql_id like nvl('&sql_id',sql_id)
and u.user_id = s.parsing_user_id
/

/* ALSO NOTE for BELOW ERROR
where upper(sql_fulltext) like upper(nvl('%SELECT "VBELN" FROM "VLKPA" WHERE "MANDT"%OR "LFART" = :A12 )',sql_fulltext))
                                                                                                          *
ERROR at line 10:
ORA-22835: Buffer too small for CLOB to CHAR or BLOB to RAW conversion (actual: 5414, maximum: 4000)

This is caused in 10g for sure,  when you use TO_CHAR on a CLOB column with over 4000 characters, 
it produces the error that we are getting. 
altough we are not using TO_CHAR but i think it getting that error when we are using the upper and nvl function...
so to get rid of that, run the above sql with ONLY

sql_fulltext like '%&sql_fulltext'

above SQL would look like this (give % at the end as well if not working)


select sql_id, child_number, plan_hash_value plan_hash, HASH_VALUE, executions execs, elapsed_time/1000000 etime,
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime, u.username,
cpu_time/1000 cpu_ms,
--11g PHYSICAL_READ_BYTES/1024/1024/1024 PHYSICAL_READ_GB,
--11g     PHYSICAL_READ_BYTES/1024/1024/decode(nvl(executions,0),0,1,executions) PIO_MB_PE,
     buffer_gets/decode(nvl(executions,0),0,1,executions) LIOS_PE,
     disk_reads/decode(nvl(executions,0),0,1,executions) PIOS_PE,USERS_EXECUTING,
sql_text, LAST_ACTIVE_TIME, LAST_LOAD_TIME,EXACT_MATCHING_SIGNATURE,FORCE_MATCHING_SIGNATURE
from v$sql s, dba_users u
where sql_fulltext like '%&sql_fulltext'
and upper(sql_fulltext) not like 'EXPLAIN PLAN%' and sql_fulltext not like 'select sql_id, child_number, plan_hash_va%'
and sql_id like nvl('&sql_id',sql_id)
and u.user_id = s.parsing_user_id;

*/