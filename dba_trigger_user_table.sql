ACCEPT owner prompt 'Enter owner name  : '
ACCEPT table prompt 'Enter table_name or blank for all name  : '

select	trigger_name
,	trigger_type
,       table_name
,	status
from	dba_triggers
where	owner = upper('&owner')
and	table_name like upper(nvl('%&table%', table_name))
order by status, trigger_name;