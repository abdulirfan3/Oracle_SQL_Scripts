-- | PURPOSE  : Report on all Oracle installed options.                         |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999
SET VERIFY   OFF

COLUMN parameter  FORMAT a45   HEADING 'Option Name'
COLUMN value      FORMAT a10   HEADING 'Installed?'

SELECT
    parameter
  , value
FROM
    v$option
ORDER BY
    parameter;
