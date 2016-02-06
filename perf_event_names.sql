-- | PURPOSE  : Reports on all defined event names included in the Oracle Wait  |
-- |            Interface.                                                      |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET PAGESIZE 9999999
SET VERIFY   OFF

COLUMN event#      FORMAT 999999      HEADING 'Event #'
COLUMN name        FORMAT a58      HEADING 'Event Name'
COLUMN parameter1  FORMAT a32      HEADING 'Parameter 1' TRUNC
COLUMN parameter2  FORMAT a12      HEADING 'Parameter 2' TRUNC
COLUMN parameter3  FORMAT a14      HEADING 'Parameter 3' TRUNC


SELECT
    en.event#               event#
  , en.name                 name
  , en.parameter1           parameter1
  , en.parameter2           parameter2
  , en.parameter3           parameter3
FROM v$event_name  en
ORDER BY 2
/
