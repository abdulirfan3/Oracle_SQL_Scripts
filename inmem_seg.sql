--inmem_segs
col owner for a15
col segment_name for a30
col orig_size_megs for 999,999.9
col in_mem_size_megs for 999,999.9
col megs_not_populated for 999,999.9
col comp_ratio for 99.9
compute sum of in_mem_size_megs on report
break on report

prompt
prompt ##### Number of tables in-memory based on priority  #######
select count(*), INMEMORY_PRIORITY from dba_tables where INMEMORY='ENABLED' group by INMEMORY_PRIORITY;

SELECT v.owner, v.segment_name,
v.bytes/(1024*1024) org_mb,
v.inmemory_size/(1024*1024) inmem_size_mb,
(v.bytes - v.bytes_not_populated) / v.inmemory_size comp_ratio,
v.INMEMORY_PRIORITY prio, v.INMEMORY_COMPRESSION comp, v.bytes_not_populated/(1024*1024) miss_mb,v.populate_status status
FROM v$im_segments v
where owner like nvl('&owner',owner)
and segment_name like nvl('&segment_name',segment_name);

/* SAME AS ABOVE but in GB

select segment_name,ROUND(SUM(BYTES)/1024/1024/1024,2) "Orig. Bytes GB", 
ROUND(SUM(INMEMORY_SIZE)/1024/1024/1024,2) "In-memory GB", 
ROUND(SUM(BYTES-BYTES_NOT_POPULATED)*100/SUM(BYTES),2) "% bytes in-memory", 
ROUND(SUM(BYTES-BYTES_NOT_POPULATED)/SUM(INMEMORY_SIZE),2) "compression ratio" 
from V$IM_SEGMENTS group by owner,segment_name order by SUM(bytes) desc;

*/


Prompt
Prompt ##### Dynamic Memory Components  #######
select substr(component,1,20) as component,current_size/1024/1024/1024 as current_size_GB 
from v$memory_dynamic_components 
where current_size != 0 and component not like 'PGA%' order by current_size desc;

Prompt
Prompt ##### IM pools being used and the current population status  #######
select POOL, ROUND(ALLOC_BYTES/1024/1024/1024,2) as "ALLOC_BYTES_GB", 
ROUND(USED_BYTES/1024/1024/1024,2) as "USED_BYTES_GB", populate_status 
from V$INMEMORY_AREA; 