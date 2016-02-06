-- | PURPOSE  : List all currently connected user sessions ordered by current   |
-- |            PGA size.                                                       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999

COLUMN sid                     FORMAT 99999          HEADING 'SID'
COLUMN serial_id               FORMAT 999999         HEADING 'Serial#'
COLUMN session_status          FORMAT a9             HEADING 'Status'          JUSTIFY right
COLUMN oracle_username         FORMAT a12            HEADING 'Oracle User'     JUSTIFY right
COLUMN os_username             FORMAT a9             HEADING 'O/S User'        JUSTIFY right
COLUMN os_pid                  FORMAT 9999999        HEADING 'O/S PID'         JUSTIFY right
COLUMN session_program         FORMAT a18            HEADING 'Session Program' TRUNC
COLUMN session_machine         FORMAT a8             HEADING 'Machine'         JUSTIFY right TRUNC
COLUMN session_pga_memory      FORMAT 9,999,999,999  HEADING 'PGA Memory'
COLUMN session_pga_memory_max  FORMAT 9,999,999,999  HEADING 'PGA Memory Max'
COLUMN session_uga_memory      FORMAT 9,999,999,999  HEADING 'UGA Memory'
COLUMN session_uga_memory_max  FORMAT 9,999,999,999  HEADING 'UGA Memory MAX'

prompt 
prompt +----------------------------------------------------+
prompt | User Sessions Ordered by Current PGA Size          |
prompt +----------------------------------------------------+

SELECT
    s.sid                sid
  , s.serial#            serial_id
  , lpad(s.status,9)     session_status
  , lpad(s.username,12)  oracle_username
  , lpad(s.osuser,9)     os_username
  , lpad(p.spid,7)       os_pid
  , s.program            session_program
  , lpad(s.machine,8)    session_machine
  , sstat1.value         session_pga_memory
  , sstat2.value         session_pga_memory_max
  , sstat3.value         session_uga_memory
  , sstat4.value         session_uga_memory_max
FROM 
    v$process  p
  , v$session  s
  , v$sesstat  sstat1
  , v$sesstat  sstat2
  , v$sesstat  sstat3
  , v$sesstat  sstat4
  , v$statname statname1
  , v$statname statname2
  , v$statname statname3
  , v$statname statname4
WHERE
      p.addr (+)            = s.paddr
  AND s.sid                 = sstat1.sid
  AND s.sid                 = sstat2.sid
  AND s.sid                 = sstat3.sid
  AND s.sid                 = sstat4.sid
  AND statname1.statistic#  = sstat1.statistic#
  AND statname2.statistic#  = sstat2.statistic#
  AND statname3.statistic#  = sstat3.statistic#
  AND statname4.statistic#  = sstat4.statistic#
  AND statname1.name        = 'session pga memory'
  AND statname2.name        = 'session pga memory max'
  AND statname3.name        = 'session uga memory'
  AND statname4.name        = 'session uga memory max'
ORDER BY session_pga_memory DESC
/
