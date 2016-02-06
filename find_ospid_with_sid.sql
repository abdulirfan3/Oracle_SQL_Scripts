select p.spid, s.sid, s.serial#, s.username, s.status from v$process p, v$session s
where p.addr = s.paddr
and s.sid = &sid;