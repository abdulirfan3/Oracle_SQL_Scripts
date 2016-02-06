col member format a50
select l.group#, l.THREAD#, l.SEQUENCE#, l.members, l.bytes/1024/1024 "MB", l.status , lf.member
from
v$logfile lf, v$log l
where lf.group#=l.group#
order by l.SEQUENCE#;