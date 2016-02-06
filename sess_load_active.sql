column uname format a10
COLUMN spio     FORMAT 999,999,999,999  Heading 'Sess|Physical Reads'
COLUMN slio     FORMAT 999,999,999,999  Heading 'Sess|Logical Reads'
COLUMN dr       FORMAT 999,999,999,999  Heading 'Disk Reads'
COLUMN BG     FORMAT 999,999,999,999  Heading 'Buffer Gets'
COLUMN time       Heading 'Logon|Time_M'
select
  s.sid            sid,
  s.process        S_client_Pid,
  s.username        uname,
  round((sysdate-s.logon_time)*24*60, 2) time,
--  (t2.value)/100    scpu,
  t1.value spio, --/1000             pio,
  t2.value  slio, --/1000/1000     lio,
--  t1.value/1024/1024    rs,
--  s.sql_address        sa,
  s.sql_id        id,
  q.disk_reads dr, --/1000    dr,
  q.buffer_gets bg,--/1000/1000    bg,
  q.rows_processed rowx, --/1000    rowx,
  q.cpu_time/1000000 cpu_s, --/60           cpu,
  round((q.elapsed_time/1000000)/60,4)       etime_m,
 -- (q.elapsed_time/1000000)/(q.disk_reads+0.00000001)      pio_time,
 -- (q.elapsed_time/1000000)/(q.buffer_gets+0.00000001)     lio_time,
  q.executions                    exe,
  substr(q.sql_text,1,4)                  stype,
  q.disk_reads+q.buffer_gets load
from
  v$session s,
  v$sqlarea q,
  v$sesstat t1,
  v$sesstat t2,
  v$statname st1,
  v$statname st2
  --v$transaction r,
  --( select value blksize from   v$parameter where  name = 'db_block_size' ) x
where
  s.sql_address = q.address and
  s.sid         = t1.sid and
  s.sid         = t2.sid and
  st1.statistic# = t1.statistic# and
  st2.statistic# = t2.statistic# and
  st1.name = 'physical reads' and  
  st2.name = 'session logical reads'AND    
  s.status = 'ACTIVE'    
order by
  load desc
;
