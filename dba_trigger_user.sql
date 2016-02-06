ACCEPT owner prompt 'Enter owner name  : '

select owner	
,   trigger_name
,	trigger_type
,	table_name
,	status
from	dba_triggers
where	owner = upper('&owner')
order by status, table_name;