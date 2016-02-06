-- | PURPOSE  : Provide a listing of all current RMAN operations and their      |
-- |            estimated timings.                                              |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET PAGESIZE 9999

COLUMN sid                              HEADING 'Oracle|SID'
COLUMN serial_num                       HEADING 'Serial|#'
COLUMN opname           FORMAT a30      HEADING 'RMAN|Operation'
COLUMN start_time       FORMAT a18      HEADING 'Start|Time'
COLUMN totalwork                        HEADING 'Total|Work'
COLUMN sofar                            HEADING 'So|Far'
COLUMN pct_done                         HEADING 'Percent|Done'
COLUMN elapsed_seconds                  HEADING 'Elapsed|Seconds'
COLUMN time_remaining                   HEADING 'Seconds|Remaining'
COLUMN done_at          FORMAT a18      HEADING 'Done|At'


SELECT
    sid                                             sid
  , serial#                                         serial_num
  , b.opname                                        opname
  , TO_CHAR(b.start_time, 'mm/dd/yy HH24:MI:SS')    start_time
  , b.totalwork                                     totalwork
  , b.sofar                                         sofar
  , ROUND( (b.sofar/DECODE(   b.totalwork
                            , 0
                            , 0.001
                            , b.totalwork)*100),2)  pct_done
  , b.elapsed_seconds                               elapsed_seconds
  , b.time_remaining                                time_remaining
  , DECODE(   b.time_remaining
            , 0
            , TO_CHAR((b.start_time + b.elapsed_seconds/3600/24), 'mm/dd/yy HH24:MI:SS')
            , TO_CHAR((SYSDATE + b.time_remaining/3600/24), 'mm/dd/yy HH24:MI:SS')
    ) done_at
FROM
       v$session         a
  JOIN v$session_longops b USING (sid,serial#)
WHERE
      a.program LIKE 'rman%'
  AND b.opname LIKE 'RMAN%'
  AND b.opname NOT LIKE '%aggregate%'
  AND b.totalwork > 0
ORDER BY
    b.start_time
/

