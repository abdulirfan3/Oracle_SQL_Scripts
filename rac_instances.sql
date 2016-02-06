-- | PURPOSE  : Provide a summary report of all configured instances for the    |
-- |            current clustered database.                                     |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET PAGESIZE  9999
SET VERIFY    off

COLUMN instance_name          FORMAT a13         HEAD 'Instance|Name / Number'
COLUMN thread#                FORMAT 99999999    HEAD 'Thread #'
COLUMN host_name              FORMAT a13         HEAD 'Host|Name'
COLUMN status                 FORMAT a6          HEAD 'Status'
COLUMN startup_time           FORMAT a20         HEAD 'Startup|Time'
COLUMN database_status        FORMAT a8          HEAD 'Database|Status'
COLUMN archiver               FORMAT a8          HEAD 'Archiver'
COLUMN logins                 FORMAT a10         HEAD 'Logins?'
COLUMN shutdown_pending       FORMAT a8          HEAD 'Shutdown|Pending?'
COLUMN active_state           FORMAT a6          HEAD 'Active|State'
COLUMN version                                   HEAD 'Version'

SELECT
    instance_name || ' (' || instance_number || ')' instance_name
  , thread#
  , host_name
  , status
  , TO_CHAR(startup_time, 'DD-MON-YYYY HH:MI:SS') startup_time
  , database_status
  , archiver
  , logins
  , shutdown_pending
  , active_state
  , version
FROM
    gv$instance
ORDER BY
    instance_number
/
