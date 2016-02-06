-- | PURPOSE  : Rollback contention report.                                     |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+
set tabo off
SET PAGESIZE 9999

COLUMN class   FORMAT a18     HEADING 'Class'    
COLUMN ratio                  HEADING 'Wait Ratio'       


SELECT
    w.class                             class
  , ROUND(100*(w.count/SUM(s.value)),8) ratio
FROM
    v$waitstat  w
  , v$sysstat   s
WHERE
      w.class IN (  'system undo header'
                  , 'system undo block'
                  , 'undo header'
                  , 'undo block'
                 )
  AND s.name IN ('db block gets', 'consistent gets')
GROUP BY w.class, w.count
/

