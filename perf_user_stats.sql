-- | PURPOSE  : List all currently connected user sessions ordered by Logical   |
-- |            I/O. This report contains all common statistics for each user   |
-- |            connection.                                                     |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999

COLUMN sid                 FORMAT 99999            HEADING 'SID'
COLUMN session_status      FORMAT a8               HEADING 'Status'          JUSTIFY right
COLUMN oracle_username     FORMAT a11              HEADING 'Oracle User'     JUSTIFY right
COLUMN session_program     FORMAT a18              HEADING 'Session Program' TRUNC
COLUMN cpu_value           FORMAT 999,999,999      HEADING 'CPU'
COLUMN logical_io          FORMAT 999,999,999,999  HEADING 'Logical I/O'
COLUMN physical_reads      FORMAT 999,999,999,999  HEADING 'Physical Reads'
COLUMN physical_writes     FORMAT 999,999,999,999  HEADING 'Physical Writes'
COLUMN session_pga_memory  FORMAT 9,999,999,999    HEADING 'PGA Memory' 
COLUMN open_cursors        FORMAT 99,999           HEADING 'Cursors'
COLUMN num_transactions    FORMAT 999,999          HEADING 'Txns'

prompt 
prompt +------------------------------------------------------+
prompt | User Sessions and Statistics Ordered by Logical I/O  |
prompt +------------------------------------------------------+

SELECT
    s.sid                sid
  , lpad(s.status,8)     session_status
  , lpad(s.username,11)  oracle_username
  , s.program            session_program
  , sstat1.value         cpu_value
  , sstat2.value +
    sstat3.value         logical_io
  , sstat4.value         physical_reads
  , sstat5.value         physical_writes
  , sstat6.value         session_pga_memory
  , sstat7.value         open_cursors
  , sstat8.value         num_transactions
FROM 
    v$process  p
  , v$session  s
  , v$sesstat  sstat1
  , v$sesstat  sstat2
  , v$sesstat  sstat3
  , v$sesstat  sstat4
  , v$sesstat  sstat5
  , v$sesstat  sstat6
  , v$sesstat  sstat7
  , v$sesstat  sstat8
  , v$statname statname1
  , v$statname statname2
  , v$statname statname3
  , v$statname statname4
  , v$statname statname5
  , v$statname statname6
  , v$statname statname7
  , v$statname statname8
WHERE
      p.addr (+)            = s.paddr	  
  AND s.sid                 = sstat1.sid
  AND s.sid                 = sstat2.sid
  AND s.sid                 = sstat3.sid
  AND s.sid                 = sstat4.sid
  AND s.sid                 = sstat5.sid
  AND s.sid                 = sstat6.sid
  AND s.sid                 = sstat7.sid
  AND s.sid                 = sstat8.sid
  AND statname1.statistic#  = sstat1.statistic#
  AND statname2.statistic#  = sstat2.statistic#
  AND statname3.statistic#  = sstat3.statistic#
  AND statname4.statistic#  = sstat4.statistic#
  AND statname5.statistic#  = sstat5.statistic#
  AND statname6.statistic#  = sstat6.statistic#
  AND statname7.statistic#  = sstat7.statistic#
  AND statname8.statistic#  = sstat8.statistic#
  AND statname1.name        = 'CPU used by this session'
  AND statname2.name        = 'db block gets'
  AND statname3.name        = 'consistent gets'
  AND statname4.name        = 'physical reads'
  AND statname5.name        = 'physical writes'
  AND statname6.name        = 'session pga memory'
  AND statname7.name        = 'opened cursors current'
  AND statname8.name        = 'user commits'
ORDER BY logical_io DESC
/
