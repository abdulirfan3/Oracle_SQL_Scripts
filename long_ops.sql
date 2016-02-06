-- long ops

col OPNAME format a25
col target format a30
prompt '----------------------------'
Prompt 'Query 2 with no where clause'
prompt '----------------------------'
select sid, opname, target, round(sofar/(totalwork+.00000000001)*100,1) "%_DONE",start_time,
elapsed_seconds
from v$session_longops
where opname not like 'Gather%'
order by start_time;


prompt '--------------------'
Prompt 'Time_remaining > 0  '
prompt '--------------------'
col opname format a20 
col target format a15 
col units format a10 
col time_remaining format 99990 heading Remaining[s] 
col bps format 9990.99 heading [Units/s] 
col fertig format 90.99 heading "complete[%]" 
select sid, 
       opname, 
       target, 
       sofar, 
       totalwork, 
       units, 
       (totalwork-sofar)/time_remaining bps, 
       time_remaining, 
       sofar/totalwork*100 fertig 
from   v$session_longops 
where  time_remaining > 0 
/ 