column  "avail Gb" format 99999.99
column  "%used"    format 999.99
column  "%free"    format 999.99
column  "Free Mb"   format 9999999.99

set hea on

select a.tablespace_name, round((b.bytes/(1024*1024*1024)),2) "avail Gb",
    (100 - nvl(round((a.bytes/b.bytes)*100,2),0))  "%used",
    nvl(round((a.bytes/b.bytes)*100,2),0) "%free", nvl(round((a.bytes)/(1024*1024),2),0) "Free Mb"
    from  sys.sm$ts_free a, sys.sm$ts_avail b, sys.sm$ts_used c
    where   a.tablespace_name = b.tablespace_name
    and   b.tablespace_name = c.tablespace_name(+)
    and nvl(round((a.bytes/b.bytes)*100,2),0)  < 20
    order by "avail Gb" desc;