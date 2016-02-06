ACCEPT owner prompt 'Enter owner name or hit enter to search all user : '
ACCEPT seg_name prompt 'Enter Search String (i.e. table name or view name) : '

Prompt
prompt +------------------------------------+
prompt |   Size of MB/GB are rounded to 2   |
Prompt +------------------------------------+

col segment_name format a25
col owner format a15

select owner
,      segment_name
,      segment_type
,      TABLESPACE_NAME
,      bytes "SIZE_BYTES"
,      Round(bytes/1024/1024,2) "SIZE_MB"
,      round(bytes/1024/1024/1024, 2) "SIZE_GB"
from   dba_segments
where  
owner like upper(nvl('%&owner%',owner))
and
segment_name like UPPER('%&seg_name%')
order by 6 asc
;