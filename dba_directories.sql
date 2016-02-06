-- | PURPOSE  : Provides a summary report of all Oracle Directory objects.      |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999
SET VERIFY   OFF

COLUMN owner            FORMAT a10   HEADING 'Owner'
COLUMN directory_name   FORMAT a30   HEADING 'Directory Name'
COLUMN directory_path   FORMAT a85   HEADING 'Directory Path'

SELECT
    owner
  , directory_name
  , directory_path
FROM
    dba_directories
ORDER BY
    owner
  , directory_name;
