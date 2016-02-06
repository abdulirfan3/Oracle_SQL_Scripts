col segment_name for a30 
col column_name for a30
undefine tbl
select
  segment_name,
  null column_name,
  segment_type,
  round(sum(bytes)/1024/1024,0) "Size(m)",a.tablespace_name,compression
from
  dba_segments a, dba_tables b
where
  a.owner = 'SAPSR3' and
  segment_name = upper('&&tbl') and
  segment_type in ('TABLE','TABLE PARTITION') and
a.owner=b.owner and a.segment_name=b.table_name
group by
a.tablespace_name,
  segment_name,
  segment_type,compression
union (
select
  segment_name,
  null column_name,
  segment_type,
  round(sum(bytes)/1024/1024,0) "Size(m)",a.tablespace_name,b.compression
from
  dba_segments a, dba_indexes b
where
  a.owner = 'SAPSR3' and
  a.owner=b.owner and
  segment_name = index_name and
  segment_type in ('INDEX','INDEX PARTITION') and
  table_name=upper('&&tbl') 
group by
a.tablespace_name,
  segment_name,
  segment_type,compression
)
union (
select
  sl.segment_name,
  l.column_name column_name,
  sl.segment_type,
  round(sl.bytes/1024/1024,0) "Size(m)",l.tablespace_name,l.compression
from
  dba_lobs l,
  dba_segments sl
where
  l.owner = 'SAPSR3' and
  l.table_name = upper('&&tbl') and
  sl.owner=l.owner and
  sl.segment_name in (l.segment_name, l.index_name)
)
order by column_name desc,segment_name
/
undefine tbl

