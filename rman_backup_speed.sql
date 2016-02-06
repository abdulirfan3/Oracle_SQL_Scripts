prompt
prompt This will only show info(MB_PER_S) after one of the backup piece finishes
prompt 
select s.client_info,
l.sid,
l.serial#,
l.sofar,
l.totalwork,
round (l.sofar / l.totalwork*100,2) "Pct_Complete",
aio.MB_PER_S,
aio.LONG_WAIT_PCT
from v$session_longops l,
v$session s,
(select sid,
serial,
100* sum (long_waits) / sum (io_count) as "LONG_WAIT_PCT",
sum (effective_bytes_per_second)/1024/1024 as "MB_PER_S"
from v$backup_async_io
group by sid, serial) aio
where aio.sid = s.sid
and aio.serial = s.serial#
and l.opname like 'RMAN%'
and l.opname not like '%aggregate%'
and l.totalwork != 0
and l.sofar <> l.totalwork
and s.sid = l.sid
and s.serial# = l.serial#
order by 1;