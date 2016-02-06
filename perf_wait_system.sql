COLUMN event             FORMAT a50                       HEADING 'Event'           
COLUMN total_waits       FORMAT 999,999,999,999,999,999   HEADING 'Total Waits'     
COLUMN total_timeouts    FORMAT 999,999,999,999,999,999   HEADING 'Total Timeouts' 
COLUMN time_waited       FORMAT 999,999,999,999,999,999   HEADING 'Time Waited'     
COLUMN average_wait      FORMAT 999,999,999,999,999,999   HEADING 'Average Wait'    

SELECT
     event   event
  , total_waits
  , total_timeouts
  , time_waited
  , average_wait
FROM
    v$system_event 
WHERE
      total_waits > 0
  AND event NOT IN (   'PX Idle Wait'
                     , 'pmon timer'
                     , 'smon timer'
                     , 'rdbms ipc message'
                     , 'parallel dequeue wait'
                     , 'parallel query dequeue'
                     , 'virtual circuit'
                     , 'SQL*Net message from client'
                     , 'SQL*Net message to client'
                     , 'SQL*Net more data to client'
                     , 'client message','Null event'
                     , 'WMON goes to sleep'
                     , 'virtual circuit status'
                     , 'dispatcher timer'
                     , 'pipe get'
                     , 'slave wait'
                     , 'KXFX: execution message dequeue - Slaves'
                     , 'parallel query idle wait - Slaves'
                     , 'lock manager wait for remote message') 
ORDER BY
    time_waited DESC;