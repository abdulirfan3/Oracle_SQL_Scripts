-- | PURPOSE  : Query all active rollback segments and the Sesions that are     |
-- |            using them. This script is RAC enabled.                         |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET PAGESIZE 9999

COLUMN instance_name  FORMAT a8      HEADING 'Instance'
COLUMN roll_name      FORMAT a13     HEADING 'Rollback Name'
COLUMN userID         FORMAT a20     HEADING 'OS/Oracle'
COLUMN usercode       FORMAT a12     HEADING 'SID/Serial#'
COLUMN program        FORMAT a31     HEADING 'Program'
COLUMN machine        FORMAT a14     HEADING 'Machine'
COLUMN status         FORMAT a8      HEADING 'Status'

SELECT
    i.instance_name                 instance_name
  , r.name                          roll_name
  , s.osuser || '/' ||  s.username  userID
  , s.sid || '/' || s.serial#       usercode
  , s.program                       program
  , s.status                        status
  , s.machine                       machine
FROM
                     gv$session  s
    INNER JOIN       gv$instance i ON (s.inst_id = i.inst_id)
    INNER JOIN       gv$lock     l ON (s.sid = l.sid AND i.inst_id = l.inst_id)
    LEFT OUTER JOIN  sys.undo$   r ON (TRUNC(l.id1/65536) = r.us#)
WHERE
      l.type  = 'TX'
  AND l.lmode = 6
ORDER BY r.name
/
