-- | PURPOSE  : Report on all components within the SGA.                        |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999
SET FEEDBACK off
SET VERIFY   off

COLUMN MB   FORMAT  999,999,999,999,999,999 Heading MB

break on report

compute sum of MB on report
--compute sum of percent on report

SELECT
     a.pool
  ,  a.name
  , a.bytes/1024/1024 as MB
FROM sys.v_$sgastat a
ORDER BY 3 
/

