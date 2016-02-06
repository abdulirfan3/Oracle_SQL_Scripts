set hea on
--ttitle center "Tablespace report Avail Gb, %Used and %Free Free Mb"  skip 2
set underline "-"

column  "avail Gb" format 99999.99
column  "%used"    format 999.99
column  "%free"    format 999.99
column  "Free Mb"   format 99999.99

set hea on
select a.tablespace_name, round((b.bytes/(1024*1024*1024)),2) "avail Gb",
    nvl(round((c.bytes/b.bytes)*100,2),0)  "%used",
  ( 100  - nvl(round((c.bytes/b.bytes)*100,2),0)) "%free", nvl(round((b.bytes - c.bytes)/(1024*1024),2),0) "Free Mb"
    from  sys.sm$ts_free a, sys.sm$ts_avail b, sys.sm$ts_used c
where   a.tablespace_name = b.tablespace_name
    and   b.tablespace_name = c.tablespace_name(+)
and  (((a.bytes/(1024*1024*1024))/(a.bytes/(1024*1024*1024))*100) - nvl(round((c.bytes/(1024*1024*1024))/(b.bytes/(1024*1024*1024))*100,2),0)) <1.5
  order by "avail Gb" desc
/




set hea off
prompt ==================================================================================
prompt Tablespace free space in locally managed tablespaces < 320Mb
prompt ==================================================================================
set hea on

select a.TABLESPACE_NAME, round(max(a.bytes/1024/1024), 0) "size Mb" from dba_free_space a, dba_tablespaces b
where b.EXTENT_MANAGEMENT='LOCAL' and b.TABLESPACE_NAME=a.TABLESPACE_NAME  and b.TABLESPACE_NAME not in
('PSAPTEMP','PSAPUNDO','PSAPES640I','PSAPES640D','PSAPEL640D', 'PSAPEL640I')
group by a.TABLESPACE_NAME having round(max(a.bytes/1024/1024), 0)  < 320
/
