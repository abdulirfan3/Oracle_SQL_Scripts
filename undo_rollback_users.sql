-- | PURPOSE  : Query all ative rollback segments and the Sesions that are      |
-- |            using them.                                                     |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

set tab off
SET PAGESIZE 9999

COLUMN roll_name FORMAT a13     HEADING 'Rollback Name'
COLUMN userID    FORMAT a20     HEADING 'OS/Oracle'
COLUMN usercode  FORMAT a12     HEADING 'SID/Serial#'
COLUMN program   FORMAT a31     HEADING 'Program'
COLUMN machine   FORMAT a14     HEADING 'Machine'
COLUMN status    FORMAT a8      HEADING 'Status'

SELECT
    r.name                          roll_name
  , s.osuser || '/' ||  s.username  userID
  , s.sid || '/' || s.serial#       usercode
  , s.program                       program
  , s.status                        status
  , s.machine                       machine
FROM
    v$lock     l
  , v$rollname r
  , v$session  s
WHERE
      s.sid = l.sid
  AND TRUNC (l.id1(+)/65536) = r.usn
  AND l.type(+) = 'TX'
  AND l.lmode(+) = 6
ORDER BY r.name
/

