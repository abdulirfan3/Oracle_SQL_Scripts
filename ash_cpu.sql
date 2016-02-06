col bar format a15
prompt +------------------------------------+
prompt |  Session samples in last 5 Mins    |
Prompt +------------------------------------+

Select
                session_id, session_serial#     ,
                count(*) ,
                round((count(*)*100)/(5*60),0) "%",
                lpad('*',round((count(*)*10)/(5*60),0),'*') "Bar"
from
                v$active_session_history
where
                session_state= 'ON CPU' and
                SAMPLE_TIME > sysdate - (5/(24*60))
group by
                session_id, session_serial#
order by
   count(*) desc;