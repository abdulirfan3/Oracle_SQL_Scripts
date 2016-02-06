prompt GIVE ONE TABLESPACE NAME OR HIT ENTER FOR ALL TABLESAPCE
column tablespace format a20 
column total_mb format 999,999,999,999.99 
column used_mb format 999,999,999,999.99 
column free_mb format 999,999,999.99 
column pct_used format 999.99 
column graph format a25 heading "GRAPH (X=5%)" 
column status format a10 
compute sum of total_mb on report 
compute sum of used_mb on report 
compute sum of free_mb on report 
break on report 
set lines 200 pages 100 
select total.ts tablespace, 
DECODE(total.gb,null,'OFFLINE',dbat.status) status, 
total.gb total_mb, 
NVL(total.gb - free.gb,total.gb) used_mb, 
NVL(free.gb,0) free_mb, 
DECODE(total.gb,NULL,0,NVL(ROUND((total.gb - free.gb)/(total.gb)*100,2),100)) pct_used, 
CASE WHEN (total.gb IS NULL) THEN '['||RPAD(LPAD('OFFLINE',13,'-'),20,'-')||']' 
ELSE '['|| DECODE(free.gb, 
null,'XXXXXXXXXXXXXXXXXXXX', 
NVL(RPAD(LPAD('X',trunc((100-ROUND( (free.gb)/(total.gb) * 100, 2))/5),'X'),20,'-'), 
'--------------------'))||']' 
END as GRAPH 
from 
(select tablespace_name ts, sum(bytes)/1024/1024 gb from dba_data_files group by tablespace_name) total, 
(select tablespace_name ts, sum(bytes)/1024/1024 gb from dba_free_space group by tablespace_name) free, 
dba_tablespaces dbat 
where total.ts=free.ts(+) and 
total.ts=dbat.tablespace_name 
and upper(total.ts) like upper(nvl('%&tbsp%',total.ts))
/*
UNION ALL 
select sh.tablespace_name, 
'TEMP', 
SUM(sh.bytes_used+sh.bytes_free)/1024/1024 total_mb, 
SUM(sh.bytes_used)/1024/1024 used_mb, 
SUM(sh.bytes_free)/1024/1024 free_mb, 
ROUND(SUM(sh.bytes_used)/SUM(sh.bytes_used+sh.bytes_free)*100,2) pct_used, 
'['||DECODE(SUM(sh.bytes_free),0,'XXXXXXXXXXXXXXXXXXXX', 
NVL(RPAD(LPAD('X',(TRUNC(ROUND((SUM(sh.bytes_used)/SUM(sh.bytes_used+sh.bytes_free))*100,2)/5)),'X'),20,'-'), 
'--------------------'))||']' 
FROM v$temp_space_header sh 
GROUP BY tablespace_name  */
order by 5 desc, 6 asc
;