col object_name format a20
col owner format a10
select owner,object_name, subobject_name, object_id, object_type, created, last_ddl_time, status 
from dba_objects
where owner=upper('&owner') and object_name=upper('&object_name');

col SAVTIME format a40
select obj#, savtime, rowcnt,blkcnt,avgrln,samplesize, analyzetime, cachedblk, cachehit, logicalread from sys.WRI$_OPTSTAT_TAB_HISTORY where obj#='&obj_nmb' order by savtime;

prompt
prompt
prompt "If no rows are returned then it means no historical info for this object, check last analyzed"
Prompt "If need more info query sys.WRI$_OPTSTAT_HISTHEAD_HISTORY"