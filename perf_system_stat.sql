col name format a50;
SELECT "Name", "Time", 100 * ROUND ("Time" / "TotalTime", 2) "Percent"
  FROM (SELECT "Name", "Time",
               (SELECT SUM ("Total Time")
                  FROM (SELECT   *
                            FROM (SELECT SUBSTR (n1.event, 1, 64) "Name",
                                         n1.time_waited "Total Time"
                                    FROM v$system_event n1
                                   WHERE n1.total_waits > 0
                                     AND event NOT LIKE '%client message%'
                                     AND event NOT LIKE
                                               '%SQL*Net message from client%'
                                     AND event NOT LIKE
                                             '%SQL*Net more data from client%'
                                     AND event NOT LIKE '%rdbms ipc message%'
                                     AND event NOT LIKE '%pipe get%'
                                     AND event NOT LIKE '%Null event%'
                                     AND event NOT LIKE '%pmon timer%'
                                     AND event NOT LIKE '%smon timer%'
                                     AND event NOT LIKE
                                                    '%parallel query dequeue%'
                                     AND event NOT LIKE
                                                    '%virtual circuit status%'
                                     AND event NOT LIKE '%dispatcher timer%'
                                     AND event NOT LIKE '%client%'
                                     AND event NOT LIKE '%PX Idle Wait%'
                                     AND event NOT LIKE
                                                     '%PX Deq: Execution Msg%'
                                     AND event NOT LIKE
                                                  '%PX Deq Credit: send blkd%'
                                     AND event NOT LIKE
                                                '%PX Deq Credit: need buffer%'
                                     AND event NOT LIKE
                                                    '%PX Deq: Table Q Normal%'
                                     AND event NOT LIKE
                                                     '%PX Deq: Execute Reply%'
                                     AND event NOT LIKE '%PX Deq: Signal ACK%'
                                     AND event NOT LIKE '%PX Deque wait%'
                                     AND event NOT LIKE '%Streams AQ:%'
                                     AND event NOT LIKE '%EMON idle wait%'
                                     AND event NOT LIKE '%i/o slave wait%'
                                     AND event NOT LIKE '%DIAG idle wait%'
                                     AND event NOT LIKE
                                            '%Space Manager: slave idle wait%'
                                     AND event NOT LIKE '%fbar timer%'
                                     AND event NOT LIKE '%jobq slave wait%'
                                     AND event NOT LIKE 'VKRM Idle%'
                                     AND event NOT LIKE
                                            'wait for unread message on broadcast channel%'
                                  UNION ALL
                                  SELECT NAME, VALUE
                                    FROM v$sysstat
                                   WHERE VALUE > 0
                                     AND NAME = 'CPU used by this session')
                        ORDER BY 2 DESC)
                 WHERE ROWNUM < 11) "TotalTime"
          FROM (SELECT   *
                    FROM (SELECT SUBSTR (n1.event, 1, 64) "Name",
                                 n1.time_waited "Time"
                            FROM v$system_event n1
                           WHERE n1.total_waits > 0
                             AND event NOT LIKE '%client message%'
                             AND event NOT LIKE
                                               '%SQL*Net message from client%'
                             AND event NOT LIKE
                                             '%SQL*Net more data from client%'
                             AND event NOT LIKE '%rdbms ipc message%'
                             AND event NOT LIKE '%pipe get%'
                             AND event NOT LIKE '%Null event%'
                             AND event NOT LIKE '%pmon timer%'
                             AND event NOT LIKE '%smon timer%'
                             AND event NOT LIKE '%parallel query dequeue%'
                             AND event NOT LIKE '%virtual circuit status%'
                             AND event NOT LIKE '%dispatcher timer%'
                             AND event NOT LIKE '%client%'
                             AND event NOT LIKE '%PX Idle Wait%'
                             AND event NOT LIKE '%PX Deq: Execution Msg%'
                             AND event NOT LIKE '%PX Deq Credit: send blkd%'
                             AND event NOT LIKE '%PX Deq Credit: need buffer%'
                             AND event NOT LIKE '%PX Deq: Table Q Normal%'
                             AND event NOT LIKE '%PX Deq: Execute Reply%'
                             AND event NOT LIKE '%PX Deq: Signal ACK%'
                             AND event NOT LIKE '%PX Deque wait%'
                             AND event NOT LIKE '%Streams AQ:%'
                             AND event NOT LIKE '%EMON idle wait%'
                             AND event NOT LIKE '%i/o slave wait%'
                             AND event NOT LIKE '%DIAG idle wait%'
                             AND event NOT LIKE
                                            '%Space Manager: slave idle wait%'
                             AND event NOT LIKE '%fbar timer%'
                             AND event NOT LIKE '%jobq slave wait%'
                             AND event NOT LIKE 'VKRM Idle%'
                             AND event NOT LIKE
                                    'wait for unread message on broadcast channel%'
                          UNION ALL
                          SELECT NAME, VALUE
                            FROM v$sysstat
                           WHERE VALUE > 0
                             AND NAME = 'CPU used by this session')
                ORDER BY 2 DESC)
         WHERE ROWNUM < 11);