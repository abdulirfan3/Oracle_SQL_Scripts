-- | PURPOSE  : Query all control files from the database.                      |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999

COLUMN name       FORMAT A45    HEADING "Controlfile Name"
COLUMN status                   HEADING "Status"

SELECT
    name
  , LPAD(status, 7) status
FROM v$controlfile
ORDER BY name
/

