-- | PURPOSE  : Provide an overview of the current state of the Flashback       |
-- |            database feature. First check that Flashback Database is        |
-- |            enabled. Next, provide an overview of the retention policy      |
-- |            settings and estimated size of the Flashback Logs.              |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999

COLUMN dbid                                HEADING 'DB ID'
COLUMN name             FORMAT A15         HEADING 'DB Name'
COLUMN log_mode         FORMAT A18         HEADING 'Log Mode'
COLUMN flashback_on     FORMAT A18         HEADING 'Flashback DB On?'

SELECT
    dbid
  , name
  , log_mode
  , flashback_on
FROM v$database;

COLUMN oldest_flashback_scn                               HEADING 'Oldest|Flashback SCN'
COLUMN oldest_flashback_time    FORMAT A21                HEADING 'Oldest|Flashback Time' JUST right
COLUMN retention_target         FORMAT 999,999            HEADING 'Retention|Target (min)'
COLUMN flashback_size           FORMAT 9,999,999,999,999  HEADING 'Flashback|Size'
COLUMN estimated_flashback_size FORMAT 9,999,999,999,999  HEADING 'Estimated|Flashback Size'

SELECT
    oldest_flashback_scn
  , TO_CHAR(oldest_flashback_time, 'DD-MON-YYYY HH24:MI:SS') oldest_flashback_time
  , retention_target
  , flashback_size
  , estimated_flashback_size
FROM v$flashback_database_log;
