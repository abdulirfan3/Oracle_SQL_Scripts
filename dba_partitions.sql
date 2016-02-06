col table_name format a40
ACCEPT owner prompt 'Enter owner name : '
ACCEPT table_name prompt 'Enter table_name or hit enter to list all partitions : '
select	table_name
,	partitioning_type type
,	partition_count partitions
from	dba_part_tables
where	owner = upper('&owner')
and table_name like upper(nvl('%&table_name%',table_name))
order by 1;