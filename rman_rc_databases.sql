-- | PURPOSE  : Provide a listing of all databases found in the RMAN recovery   |
-- |            catalog.                                                        |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999

COLUMN db_key                 FORMAT 999999                 HEADING 'DB|Key'
COLUMN dbinc_key              FORMAT 999999                 HEADING 'DB Inc|Key'
COLUMN dbid                                                 HEADING 'DBID'
COLUMN name                   FORMAT a12                    HEADING 'Database|Name'
COLUMN resetlogs_change_num                                 HEADING 'Resetlogs|Change Num'
COLUMN resetlogs              FORMAT a21                    HEADING 'Reset Logs|Date/Time'

prompt
prompt Listing of all databases in the RMAN recovery catalog
prompt 

SELECT
    rd.db_key
  , rd.dbinc_key
  , rd.dbid
  , rd.name
  , rd.resetlogs_change#                                 resetlogs_change_num
  , TO_CHAR(rd.resetlogs_time, 'DD-MON-YYYY HH24:MI:SS') resetlogs
FROM
    rman.rc_database   rd
ORDER BY
    rd.name
/
