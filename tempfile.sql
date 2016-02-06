-- for temp file
set pages 999 feed on newpage 1
col file_name for a50 trunc
col status for a5 trunc
col extbl  for a5 trunc
col MB  for 999,999
col maxMB for 999,999
select a.file_name,
       a.file_id,
       a.status,
       a.autoextensible extbl,
       (bytes/1024/1024) MB,
       (maxbytes/1024/1024) MaxMB
from dba_temp_files a
order by 2;