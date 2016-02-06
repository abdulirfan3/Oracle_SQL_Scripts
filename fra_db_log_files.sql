-- | PURPOSE  : Provide a list of all Flasback log files.                       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999

COLUMN thread#                                            HEADING 'Thread #'
COLUMN sequence#                                          HEADING 'Sequence #'
COLUMN name                     FORMAT a59                HEADING 'Log File Name'
COLUMN log#                                               HEADING 'Log #'
COLUMN bytes                    FORMAT 9,999,999,999      HEADING 'Bytes'
COLUMN first_change#                                      HEADING 'First Change #'
COLUMN first_time                                         HEADING 'First Time' JUST RIGHT

BREAK ON thread# SKIP 2
COMPUTE COUNT OF sequence# ON thread#
COMPUTE SUM OF bytes ON thread#

SELECT
    thread#
  , sequence#
  , name
  , log#
  , bytes
  , first_change#
  , TO_CHAR(first_time, 'DD-MON-YYYY HH24:MI:SS') first_time
FROM 
    v$flashback_database_logfile
ORDER BY
    thread#
  , sequence#;
