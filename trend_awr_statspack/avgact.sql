
-- (c) Kyle Hailey 2007
/* April 2, 2008 Philippe Faro correction on count by 10 in historical totals 
   April 8, 2008 Kaj Korfits Møller changed calc to filter out background waits */

accept hours prompt "hours (default 12) : " default 12 
column f_hours new_value v_hours
select &hours f_hours from dual;
column f_secs new_value v_secs
column f_samples new_value samples
select 3600 f_secs from dual;
select &v_secs f_samples from dual;
--select &seconds f_secs from dual;
column f_bars new_value v_bars
select 5 f_bars from dual;
column aas format 999.99
column f_graph new_value v_graph
select 30 f_graph from dual;
column graph format a30
column total format 99999
column npts format 99999
col waits for 99999
col cpu for 9999

/*
      dba_hist_active_sess_history
*/
select
        to_char(to_date(tday||' '||tmod*&v_secs,'YYMMDD SSSSS'),'DD-MON  HH24:MI:SS') tm,
        samples npts,
        total/&samples aas,
        substr(
        substr(substr(rpad('+',round((cpu*&v_bars)/&samples),'+') ||
        rpad('-',round((waits*&v_bars)/&samples),'-')  ||
        rpad(' ',p.value * &v_bars,' '),0,(p.value * &v_bars)) ||
        p.value  ||
        substr(rpad('+',round((cpu*&v_bars)/&samples),'+') ||
        rpad('-',round((waits*&v_bars)/&samples),'-')  ||
        rpad(' ',p.value * &v_bars,' '),(p.value * &v_bars),10) ,0,30)
        ,0,&v_graph)
        graph,
        -- total,
        cpu,
        waits
from (
   select
       to_char(sample_time,'YYMMDD')                   tday
     , trunc(to_char(sample_time,'SSSSS')/&v_secs) tmod
     , sum(decode(session_state,'ON CPU',1,decode(session_type,'BACKGROUND',0,1)))  total
     , (max(sample_id) - min(sample_id) + 1 )      samples
     , sum(decode(session_state,'ON CPU' ,1,0))    cpu
     , sum(decode(session_type,'BACKGROUND',0,decode(session_state,'WAITING',1,0))) waits
       /* for waits I want to subtract out the BACKGROUND
          but for CPU I want to count everyon */
   from
      v$active_session_history
   where sample_time > sysdate - &v_hours/24
   group by  trunc(to_char(sample_time,'SSSSS')/&v_secs),
             to_char(sample_time,'YYMMDD')
union all
   select
       to_char(sample_time,'YYMMDD')                   tday
     , trunc(to_char(sample_time,'SSSSS')/&v_secs) tmod
     , sum(decode(session_state,'ON CPU',10,decode(session_type,'BACKGROUND',0,10)))  total
     , (max(sample_id) - min(sample_id) + 1 )      samples
     , sum(decode(session_state,'ON CPU' ,10,0))    cpu
     , sum(decode(session_type,'BACKGROUND',0,decode(session_state,'WAITING',10,0))) waits
       /* for waits I want to subtract out the BACKGROUND
          but for CPU I want to count everyon */
   from
      dba_hist_active_sess_history
   where sample_time > sysdate - &v_hours/24
   and sample_time < (select min(sample_time) from v$active_session_history)
   group by  trunc(to_char(sample_time,'SSSSS')/&v_secs),
             to_char(sample_time,'YYMMDD')
) ash,
  v$parameter p
where p.name='cpu_count'
order by to_date(tday||' '||tmod*&v_secs,'YYMMDD SSSSS')
;