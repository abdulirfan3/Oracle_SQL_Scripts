set lines 155
col sql_text for a35 trunc
col last_executed for a28
col enabled for a7
col plan_hash_value for a16
col last_executed for a16
select spb.sql_handle, spb.plan_name, to_char(so.plan_id) plan_hash_value,
dbms_lob.substr(sql_text,3999,1) sql_text,
spb.enabled, spb.accepted, spb.fixed,
to_char(spb.last_executed,'dd-mon-yy HH24:MI') last_executed
from
dba_sql_plan_baselines spb, sqlobj$ so
where spb.signature = so.signature
and spb.plan_name = so.name
and dbms_lob.substr(sql_text,3999,1) like nvl('&sql_text', dbms_lob.substr(sql_text,3999,1))
-- spb.sql_text like nvl('%'||'&sql_text'||'%',spb.sql_text)
and spb.sql_handle like nvl('&name',spb.sql_handle)
and spb.plan_name like nvl('&plan_name',spb.plan_name)
/
