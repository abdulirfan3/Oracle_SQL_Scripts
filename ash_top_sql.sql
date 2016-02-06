prompt
prompt +------------------------------------+
prompt |  Session samples in last 5 Mins    |
Prompt +------------------------------------+
prompt

select * from (
SELECT ash.sql_id,
       SUM(DECODE(ash.session_state, 'ON CPU', 1, 0))        "CPU",
       SUM(DECODE(ash.session_state, 'WAITING', 1, 0))
               - SUM( DECODE(ash.session_state, 'WAITING', DECODE(en.wait_class, 'User I/O', 1, 0), 0)) "WAIT",
       SUM(DECODE(ash.session_state, 'WAITING',  DECODE(en.wait_class, 'User I/O', 1, 0),  0))        "IO",
       SUM(DECODE(ash.session_state, 'ON CPU', 1,   1))       "TOTAL"
FROM   v$active_session_history ash,
       v$event_name en
WHERE  sql_id IS NOT NULL AND SAMPLE_TIME >  SYSDATE - (5/(24*60))
       AND en.event# = ash.event#
GROUP  BY sql_id
ORDER  BY 5 desc) where rownum < 16;