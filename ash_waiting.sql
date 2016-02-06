col bar format a15
prompt +------------------------------------+
prompt |  Session samples in last 5 Mins    |
Prompt +------------------------------------+

Select
                session_id, 
                count(*) 
from
                v$active_session_history
where
                session_state= 'WAITING' and
                SAMPLE_TIME > sysdate - (5/(24*60))
group by
                session_id
order by
   count(*) desc;