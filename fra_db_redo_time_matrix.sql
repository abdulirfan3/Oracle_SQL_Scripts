-- | PURPOSE  : Provide details on the amount of redo data being collected by   |
-- |            Oracle Flashback Database over given time frames.               |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999

COLUMN begin_time               FORMAT A21                HEADING 'Begin Time'
COLUMN end_time                 FORMAT A21                HEADING 'End Time'
COLUMN flashback_data           FORMAT 9,999,999,999,999  HEADING 'Flashback Data'
COLUMN db_data                  FORMAT 9,999,999,999,999  HEADING 'DB Data'
COLUMN redo_data                FORMAT 9,999,999,999,999  HEADING 'Redo Data'
COLUMN estimated_flashback_size FORMAT 9,999,999,999,999  HEADING 'Estimated|Flashback Size'

SELECT
    TO_CHAR(begin_time, 'DD-MON-YYYY HH24:MI:SS') begin_time
  , TO_CHAR(end_time, 'DD-MON-YYYY HH24:MI:SS') end_time
  , flashback_data
  , db_data
  , redo_data
  , estimated_flashback_size
FROM
    v$flashback_database_stat
ORDER BY
   begin_time;

