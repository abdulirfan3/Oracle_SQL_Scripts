ALTER SESSION enable parallel query;
col owner for a20
select /*+ FULL(DBA_TABLES) PARALLEL(DBA_TABLES,5) */ distinct owner,to_char(LAST_ANALYZED,'DD-MON-YY') LAST_ANAZ,count(*) from 
DBA_TABLES where owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','ORACLE','PERFSTAT','OPS$ORACLE') 
group by owner,to_char(LAST_ANALYZED,'DD-MON-YY') order by 1;

