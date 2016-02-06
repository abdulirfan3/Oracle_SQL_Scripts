-- | PURPOSE  : List all currently connected user sessions ordered by the       |
-- |            number of current open cursors within their session.            |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999

COLUMN sid               FORMAT 99999            HEADING 'SID'
COLUMN serial_id         FORMAT 999999           HEADING 'Serial#'
COLUMN session_status    FORMAT a9               HEADING 'Status'          JUSTIFY right
COLUMN oracle_username   FORMAT a12              HEADING 'Oracle User'     JUSTIFY right
COLUMN os_username       FORMAT a9               HEADING 'O/S User'        JUSTIFY right
COLUMN os_pid            FORMAT 9999999          HEADING 'O/S PID'         JUSTIFY right
COLUMN session_program   FORMAT a20              HEADING 'Session Program' TRUNC
COLUMN session_machine   FORMAT a14              HEADING 'Machine'         JUSTIFY right TRUNC
COLUMN open_cursors      FORMAT 99,999           HEADING 'Open Cursors'
COLUMN open_pct          FORMAT 999              HEADING 'Open %'

prompt 
prompt +----------------------------------------------------+
prompt | User Sessions Ordered by Number of Open Cursors    |
prompt +----------------------------------------------------+

SELECT
    s.sid                sid
  , s.serial#            serial_id
  , lpad(s.status,9)     session_status
  , lpad(s.username,12)  oracle_username
  , lpad(s.osuser,9)     os_username
  , lpad(p.spid,7)       os_pid
  , s.program            session_program
  , lpad(s.machine,14)   session_machine
  , sstat.value          open_cursors
  , ROUND((sstat.value/u.value)*100) open_pct
FROM 
    v$process  p
  , v$session  s
  , v$sesstat  sstat
  , v$statname statname
  , (select name, value
     from v$parameter) u
WHERE
      p.addr (+)          = s.paddr
  AND s.sid               = sstat.sid
  AND statname.statistic# = sstat.statistic#
  AND statname.name       = 'opened cursors current'
  AND u.name              = 'open_cursors'
ORDER BY open_cursors DESC
/
