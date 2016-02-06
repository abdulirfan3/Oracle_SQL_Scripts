col owner format a10
col index_name format a30
col table_name format a30
col index_type format a10
col table_owner format a10
 
 
 ACCEPT owner prompt 'Enter owner name or hit enter to search all user : '
 select di.OWNER, di.INDEX_NAME, di.INDEX_TYPE, di.TABLE_OWNER, di.TABLE_NAME, di.LAST_ANALYZED, di.PARTITIONED, di.STATUS, ds.bytes/1024/1024 "size in MB"  
 from DBA_indexes di, dba_segments ds
  WHERE di.index_name=ds.segment_name
  and di.owner like upper(nvl('%&owner%',di.owner))
  and STATUS = 'UNUSABLE';