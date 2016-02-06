-- | PURPOSE  : This script produces a report of the top sessions that have     |
-- |            waited (the entries at top have waited the longest) for         |
-- |            non-idle wait events )event column). The Oracle Server          |
-- |            Reference Manual can be used to further diagnose the wait event |
-- |            (along with its parameters). Metalink can also be used by       |
-- |            supplying the event name in the search bar.                     |
-- |                                                                            |
-- |            The INST_ID column shows the instance where the session resides |
-- |            and the SID is the unique identifier for the session            |
-- |            (gv$session).  The p1, p2, and p3 columns will show event       |
-- |            specific information that may be important to debug the         |
-- |            problem.                                                        |
-- | EXAMPLE  : For example, you can search Metalink by supplying the event     |
-- | METALINK : name (surrounded by single quotes) as in the following example: |
-- | SEARCH   :                                                                 |
-- |                          [ 'Sync ASM rebalance' ]                          |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

set tab off
SET PAGESIZE  9999
SET VERIFY    off

COLUMN instance_name          FORMAT a11         HEAD 'Instance|Name / ID'
COLUMN sid                    FORMAT a13         HEAD 'SID / Serial#'
COLUMN oracle_username                           HEAD 'Oracle|Username'
COLUMN state                  FORMAT a7          HEAD 'State'
COLUMN event                  FORMAT a25         HEAD 'Event'
COLUMN last_sql               FORMAT a25         HEAD 'Last SQL'

SELECT
    i.instance_name || ' (' || sw.inst_id || ')'  instance_name
  , sw.sid || ' / ' || s.serial#                  sid
  , s.username                                    oracle_username
  , sw.state                                      state
  , sw.event
  , sw.seconds_in_wait seconds
  , sw.p1
  , sw.p2
  , sw.p3
  , sa.sql_text last_sql
FROM
    gv$session_wait sw
        INNER JOIN gv$session s   ON  ( sw.inst_id = s.inst_id
                                        AND
                                        sw.sid     = s.sid
                                      )
        INNER JOIN gv$sqlarea sa  ON  ( s.inst_id     = sa.inst_id
                                        AND
                                        s.sql_address = sa.address
                                      )
        INNER JOIN gv$instance i  ON  ( s.inst_id = i.inst_id)
WHERE
      sw.event NOT IN (   'rdbms ipc message'
                        , 'smon timer'
                        , 'pmon timer'
                        , 'SQL*Net message from client'
                        , 'lock manager wait for remote message'
                        , 'ges remote message'
                        , 'gcs remote message'
                        , 'gcs for action'
                        , 'client message'
                        , 'pipe get'
                        , 'null event'
                        , 'PX Idle Wait'
                        , 'single-task message'
                        , 'PX Deq: Execution Msg'
                        , 'KXFQ: kxfqdeq - normal deqeue'
                        , 'listen endpoint status'
                        , 'slave wait'
                        , 'wakeup time manager'
                      )
  and sw.seconds_in_wait > 0 
ORDER BY seconds desc
/
