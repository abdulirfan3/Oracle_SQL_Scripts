select p.spid, s.sid, s.serial#, s.username, s.status, s.sql_id from v$process p, v$session s
where p.addr = s.paddr
and p.spid = &osspid;