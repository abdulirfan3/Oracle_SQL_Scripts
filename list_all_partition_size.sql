ACCEPT owner prompt 'Enter owner name : '
ACCEPT table_name prompt 'Enter table_name name : '
col tablespace_name format a20
col num_rows format 999,999,999
select	p.partition_name
,	p.tablespace_name
,	p.num_rows
,	ceil(s.bytes / 1024 / 1204) mb
from	dba_tab_partitions p
,	dba_segments s
where	p.table_owner = s.owner
and	p.partition_name = s.partition_name
and 	p.table_name = s.segment_name
and	p.table_owner = upper('&owner')
and	p.table_name = upper('&table_name')
order by partition_position;