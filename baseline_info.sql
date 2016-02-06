--set lines 155
col sql_text for a100 
col last_executed for a28
col enabled for a7
col plan_hash_value for a16
col last_executed for a16
col signature format 999999999999999999999999999999
select spb.sql_handle, spb.plan_name, spb.origin,
spb.enabled, spb.accepted, spb.fixed, spb.OPTIMIZER_COST, spb.EXECUTIONS, spb.creator,
to_char(spb.last_executed,'dd-mon-yy HH24:MI') last_executed, spb.CREATED, spb.sql_text, spb.SIGNATURE,DESCRIPTION
from
dba_sql_plan_baselines spb
where spb.sql_text like nvl('%'||'&sql_text'||'%',spb.sql_text)
and spb.sql_handle like nvl('&name',spb.sql_handle)
and spb.plan_name like nvl('&plan_name',spb.plan_name)
order by 1
/