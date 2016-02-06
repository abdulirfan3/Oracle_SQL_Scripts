select 
    child_number    sql_child_number,
 --   address        parent_handle,
--    child_address   object_handle,
    parse_calls parses,
    loads h_parses,
    executions,
 --   fetches,
    rows_processed,
    buffer_gets LIOS,
    disk_reads PIOS,
    sorts, 
--    address,
 --   cpu_time/1000 cpu_ms,
--    elapsed_time/1000 ela_ms,
--    sharable_mem,
--    persistent_mem,
--    runtime_mem,
    users_executing,
	sql_text
from 
    v$sql 
where 
    hash_value in ('&hash_value');