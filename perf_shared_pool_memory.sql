-- | PURPOSE  : Query the total memory in the Shared Pool and the amount of     |
-- |            free memory.                                                    |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999

COLUMN value       FORMAT 999,999,999,999 HEADING "Shared Pool Size"
COLUMN MB          FORMAT 999,999,999,999 HEADING "Free MB"
COLUMN percentfree FORMAT 999             HEADING "Percent Free"

SELECT
    TO_NUMBER(p.value)/1024/1024       value
  , s.bytes/1024/1024        MB
  , (s.bytes/p.value) * 100  percentfree
FROM
    v$sgastat    s
  , v$parameter  p
WHERE
      s.name = 'free memory'
  AND s.pool = 'shared pool'
  AND p.name = 'shared_pool_size'
/

