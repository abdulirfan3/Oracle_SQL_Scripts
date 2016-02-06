prompt
prompt +------------------------------------+
prompt |  Session samples in last 5 Mins    |
Prompt +------------------------------------+
prompt

select
     ash.session_id,
     ash.session_serial#,
     ash.user_id,
     ash.program,
     sum(decode(ash.session_state,'ON CPU',1,0))     "CPU",
     sum(decode(ash.session_state,'WAITING',1,0))    -
     sum(decode(ash.session_state,'WAITING',
        decode(en.wait_class,'User I/O',1, 0 ), 0))    "WAITING" ,
     sum(decode(ash.session_state,'WAITING',
        decode(en.wait_class,'User I/O',1, 0 ), 0))    "IO" ,
     sum(decode(session_state,'ON CPU',1,1))     "TOTAL"
from v$active_session_history ash,
        v$event_name en
where en.event# = ash.event#
and   ash.SAMPLE_TIME > sysdate - (5/(24*60))
group by session_id,user_id,session_serial#,program
order by sum(decode(session_state,'ON CPU',1,1));

