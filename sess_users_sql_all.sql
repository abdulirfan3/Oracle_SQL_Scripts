-- | PURPOSE  : List all currently connected users and the SQL that they are    |
-- |            running.                                                        |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999

COLUMN sid               FORMAT 99999      HEADING 'SID'
COLUMN session_status    FORMAT a9         HEADING 'Status'          JUSTIFY right
COLUMN oracle_username   FORMAT a14        HEADING 'Oracle User'     JUSTIFY right
COLUMN os_username       FORMAT a12        HEADING 'O/S User'        JUSTIFY right
COLUMN os_pid            FORMAT 9999999    HEADING 'O/S PID'         JUSTIFY right
COLUMN session_program   FORMAT a26        HEADING 'Session Program' TRUNC
COLUMN current_sql       FORMAT a45        HEADING 'Current SQL'     WRAP

prompt 
prompt +----------------------------------------------------+
prompt | All User Sessions and Current SQL                  |
prompt +----------------------------------------------------+

SELECT
    s.sid                       sid
  , lpad(s.status,9)            session_status
  , lpad(s.username,14)         oracle_username
  , lpad(s.osuser,12)           os_username
  , lpad(p.spid,7)              os_pid
  , s.program                   session_program
  , SUBSTR(sa.sql_text, 1, 600) current_sql
FROM 
    v$process p
  , v$session s
  , v$sqlarea sa
WHERE
      p.addr (+)       =  s.paddr
  AND s.sql_address    =  sa.address(+) 
  AND s.sql_hash_value =  sa.hash_value(+)
  AND s.audsid         <> userenv('SESSIONID')
  AND s.username       IS NOT NULL
ORDER BY sid
/
