-- | PURPOSE  : Displays the SQL being run by a given session given the SID.    |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


SET PAGESIZE 9999
set lines 150
set wrap off;
COLUMN sql_text FORMAT a5000 word_wrap
col DISK_READS format 999,999,999,999
COLUMN buffer_gets    FORMAT 999,999,999,999  

SELECT
    v.SID,
       v.status, v.last_call_et, a.sorts, a.disk_reads, a.buffer_gets, a.sql_text
FROM
    v$sqlarea a
  , v$session v
WHERE
      a.address = v.sql_address
  AND v.sid = '&sid';
  
set lines 500;  
