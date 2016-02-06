
SET PAGESIZE 9999

COLUMN sid               FORMAT 99999            HEADING 'SID'
COLUMN serial_id         FORMAT 999999           HEADING 'Serial#'
COLUMN session_status    FORMAT a9               HEADING 'Status'          JUSTIFY right
COLUMN oracle_username   FORMAT a12              HEADING 'User'            
COLUMN os_username       FORMAT a9               HEADING 'O/S User'        JUSTIFY right
COLUMN os_pid            FORMAT a8               HEADING 'O/S PID'         
COLUMN session_program   FORMAT a30              HEADING 'Session Program' TRUNC
COLUMN module            Format a30              Heading 'Module'          TRUNC
COLUMN session_machine   FORMAT a14              HEADING 'Machine'         JUSTIFY right TRUNC
COLUMN Logical_Reads     FORMAT 999,999,999,999  Heading 'Logical Reads'

prompt 
prompt +----------------------------------------------------+
prompt | Active User Sessions                               |
prompt +----------------------------------------------------+

SELECT
    s.sid                sid
  , s.serial#            serial_id
  , lpad(s.status,9)     session_status
  , lpad(s.username,12)  oracle_username
  , lpad(s.osuser,9)     os_username
  , p.spid               os_pid
  , ss.VALUE             Logical_Reads
  , s.SQL_HASH_VALUE   
  , s.program            session_program
  , s.module             MODULE
  , lpad(s.machine,14)   session_machine
  , TO_CHAR (logon_time, 'DD-MON-YY HH24:MI:SS') "Logged On"
 -- , s.sql_id             Sql_id
--  , sstat.value          cpu_value
FROM
    v$process  p
  , v$session  s
  , v$sesstat  ss
  , v$statname st
WHERE p.addr(+) = s.paddr
     AND s.SID = ss.SID
     AND st.statistic# = ss.statistic#
     AND s.status = 'ACTIVE'
     AND s.TYPE != 'BACKGROUND'
     AND st.NAME = 'session logical reads'
ORDER BY 11;
