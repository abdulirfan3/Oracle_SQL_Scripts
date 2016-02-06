-- for data files
-- CHECK FOR SPECIFIC TABLESPACE AND DATAFILE
prompt GIVE ONE TABLESPACE NAME OR HIT ENTER FOR ALL TABLESAPCE
prompt Also, give file name like, eg.. /oracle/sapdata, sr3, ..
set pages 999 feed on newpage 1
col tblspace for a15 trunc
col file_name for a50 trunc
col status for a5 trunc
col extbl  for a5 trunc
col MB  for 999,999
col maxMB for 999,999
select b.tablespace_name tblspace,
       a.file_name,
       a.file_id,
       b.status,
       a.autoextensible extbl,
       (bytes/1024/1024) MB,
       (maxbytes/1024/1024) MaxMB
from dba_data_files a,
     dba_tablespaces b
where a.tablespace_name = b.tablespace_name
    and upper(b.tablespace_name) like upper(nvl('%&tbsp%',b.tablespace_name))
    and a.file_name like nvl('%&file_name%',a.file_name)
order by 2;