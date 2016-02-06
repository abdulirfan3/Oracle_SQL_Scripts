set timing on
select * from
(
select
substr(segment_name,1,30) "Name",
round(sum(bytes)/1024/1024/1024) "Size (gb)",a.initial_extent,
count(*) "Partitions"
from dba_segments a,dba_tables b
where segment_type like 'TAB%' and
a.owner='SAPSR3'
and
segment_name not like 'ARFC%' and
segment_name not like 'TRFC%' and
segment_name not like 'QRFC%' and
segment_name not in ('VBHDR','VBDATA','VBMOD','VBERROR','REPOSRC','REPOLOAD','NRIV') and
a.segment_name=b.table_name and
compression!='ENABLED' 
and not exists
(select 'x' from dba_tab_cols c
where c.owner=a.owner and c.table_name=a.segment_name and c.data_type='BLOB')
group by substr(segment_name,1,30),a.initial_extent
order by 2 desc
)
where rownum<51
/
select sum("Size (gb)") "sum of top50"
from
(
select * from
(
select
substr(segment_name,1,30) "Name",
round(sum(bytes)/1024/1024/1024) "Size (gb)",
count(*) "Partitions"
from dba_segments a,dba_tables b
where segment_type like 'TAB%' and
a.owner='SAPSR3'
and
segment_name not like 'ARFC%' and
segment_name not like 'TRFC%' and
segment_name not like 'QRFC%' and
segment_name not in ('VBHDR','VBDATA','VBMOD','VBERROR','REPOSRC','REPOLOAD','NRIV') and
a.segment_name=b.table_name and
compression!='ENABLED' 
and not exists
(select 'x' from dba_tab_cols c
where c.owner=a.owner and c.table_name=a.segment_name and c.data_type='BLOB')
group by substr(segment_name,1,30)
order by 2 desc
)
where rownum<51
)
/
select sum("Size (gb)") "sum of compressable tables"
from
(
select * from
(
select
substr(segment_name,1,30) "Name",
round(sum(bytes)/1024/1024/1024) "Size (gb)",
count(*) "Partitions"
from dba_segments a,dba_tables b
where segment_type like 'TAB%' and
a.owner='SAPSR3'
and
segment_name not like 'ARFC%' and
segment_name not like 'TRFC%' and
segment_name not like 'QRFC%' and
segment_name not in ('VBHDR','VBDATA','VBMOD','VBERROR','REPOSRC','REPOLOAD','NRIV') and
a.segment_name=b.table_name and
compression!='ENABLED' 
and not exists
(select 'x' from dba_tab_cols c
where c.owner=a.owner and c.table_name=a.segment_name and c.data_type='BLOB')
group by substr(segment_name,1,30)
order by 2 desc
)
)
/


prompt
prompt
prompt ###################################################
prompt    VERSION 2
prompt ###################################################
prompt 

set timing on
select * from
(
select
substr(segment_name,1,30) "Name",
round(sum(bytes)/1024/1024/1024) "Size (gb)",a.initial_extent,
count(*) "Partitions"
from dba_segments a,dba_tables b
where segment_type like 'TAB%' and
a.owner='SAPSR3'
and
segment_name not like 'ARFC%' and
segment_name not like 'TRFC%' and
segment_name not like 'QRFC%' and
segment_name not in ('VBHDR','VBDATA','VBMOD','VBERROR','REPOSRC','REPOLOAD','NRIV') and
a.segment_name=b.table_name and
(compression ='DISABLED' or compression is null)
and not exists
(select 'x' from dba_tab_cols c
where c.owner=a.owner and c.table_name=a.segment_name and c.data_type='BLOB')
group by substr(segment_name,1,30),a.initial_extent
order by 2 desc
)
where rownum<51
/
select sum("Size (gb)") "sum of top50"
from
(
select * from
(
select
substr(segment_name,1,30) "Name",
round(sum(bytes)/1024/1024/1024) "Size (gb)",
count(*) "Partitions"
from dba_segments a,dba_tables b
where segment_type like 'TAB%' and
a.owner='SAPSR3'
and
segment_name not like 'ARFC%' and
segment_name not like 'TRFC%' and
segment_name not like 'QRFC%' and
segment_name not in ('VBHDR','VBDATA','VBMOD','VBERROR','REPOSRC','REPOLOAD','NRIV') and
a.segment_name=b.table_name and
(compression ='DISABLED' or compression is null)
and not exists
(select 'x' from dba_tab_cols c
where c.owner=a.owner and c.table_name=a.segment_name and c.data_type='BLOB')
group by substr(segment_name,1,30)
order by 2 desc
)
where rownum<51
)
/
select sum("Size (gb)") "sum of compressable tables"
from
(
select
substr(segment_name,1,30) "Name",
round(sum(bytes)/1024/1024/1024) "Size (gb)",
count(*) "Partitions"
from dba_segments a
,dba_tables b
where segment_type like 'TAB%' and
a.owner='SAPSR3'
and
segment_name not like 'ARFC%' and
segment_name not like 'TRFC%' and
segment_name not like 'QRFC%' and
segment_name not in ('VBHDR','VBDATA','VBMOD','VBERROR','REPOSRC','REPOLOAD','NRIV') and
a.segment_name=b.table_name 
and
(compression ='DISABLED' or compression is null)
and 
not exists
(select 'x' from dba_tab_cols c
where c.owner=a.owner and c.table_name=a.segment_name and c.data_type='BLOB')
group by substr(segment_name,1,30)
)
/


