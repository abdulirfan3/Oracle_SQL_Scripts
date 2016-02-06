-- | PURPOSE  : Report on top SQL statements ordered by disk reads.             |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999
SET VERIFY   off

COLUMN sid             FORMAT 99999                HEADING 'Sid'
COLUMN disk_reads      FORMAT 999,999,999,999,999  HEADING 'Disk Reads'
COLUMN buffer_gets     FORMAT 999,999,999,999,999  HEADING 'Buffer Gets'
COLUMN cpu_time        FORMAT 999,999,999,999,999  HEADING 'CPU Time'
COLUMN elapsed_time    FORMAT 999,999,999,999,999  HEADING 'Elapsed Time'
COLUMN executions      FORMAT 999,999,999,999      HEADING 'Executions'
COLUMN reads_per_exec  FORMAT 999,999,999,999,999  HEADING 'Reads / Executions'
COLUMN sql             FORMAT a120 word_wrap       HEADING 'SQL Statement'

prompt 
prompt =============================================
prompt SQL with disk reads greater than 1000 (ACTIVE)
prompt If you want to see all session, Comment out a.BUFFER_GETS > 1000
prompt =============================================

SELECT
     s.sid                                                     sid
    ,a.disk_reads                                              disk_reads
    ,a.buffer_gets                                             buffer_gets
    ,a.cpu_time                                                cpu_time
    ,a.elapsed_time                                            elapsed_time
    ,a.hash_value                                              hash_value
    , a.executions                                             executions
    , a.BUFFER_GETS / decode(a.executions, 0, 1, a.executions)  reads_per_exec
    , sql_text || chr(10) || chr(10)                           sql 
FROM 
    sys.v_$sqlarea a,
    sys.v_$session s
WHERE
s.sql_address = a.address
and   a.BUFFER_GETS > 1000
and   s.status = 'ACTIVE'
AND   S.TYPE != 'BACKGROUND'
ORDER BY
    BUFFER_GETS desc;
