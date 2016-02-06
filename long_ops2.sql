col opname for a25 trunc
col username for a15 trunc
col target for a20 
col sid for 999999
col serial# for 999999
col %DONE for a8
select b.username,a.sid,b.opname,b.target,round(b.SOFAR*100 / b.TOTALWORK,0) || '%' as "%DONE",
b.TIME_REMAINING,to_char(b.start_time,'YYYY/MM/DD HH24:MI:SS') START_TIME, to_char(b.LAST_UPDATE_TIME,'YYYY/MM/DD HH24:MI:SS') LAST_UPDATE_TIME
from V$SESSION_LONGOPS b,V$SESSION a where a.sid=b.sid and TIME_REMAINING <> 0 order by b.SOFAR/b.TOTALWORK;


