col category for a15
col sql_text for a70 trunc
select name, category, status, sql_text, force_matching
from dba_sql_profiles
where sql_text like nvl('&sql_text','%')
and name like nvl('&name',name)
order by last_modified
/

