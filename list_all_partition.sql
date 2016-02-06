select	partition_name
,	tablespace_name
,	high_value
from	dba_tab_partitions
where	table_owner = upper('&owner')
and	table_name = upper('&table_name')
order by partition_position;