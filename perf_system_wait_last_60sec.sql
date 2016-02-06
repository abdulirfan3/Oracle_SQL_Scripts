/* version 1 --most likely even bad
select * from (
select m.intsize_csec,
       n.name ,
       round(m.time_waited,3) time_waited_centi_s,
       m.wait_count,
       round(10*m.time_waited/nullif(m.wait_count,0),3) avgms
from v$eventmetric m,
     v$event_name n
where m.event_id=n.event_id
order by 4 desc)
where rownum < 35
order by 5 desc;

*/

/* 
   eventmetric.sql - sqlplus script - displays significant event metrics
   By Luca Jan 2011, 11g version Apr2012 
*/

col "Time /Delta" for a14
col name for a40
col INST_ID for 999
--set linesize 140
--set pagesize 1000

set wrap off 

select "Time /Delta",inst_id,name, 
        T_per_wait_fg*10 "Avg_FG_wait_ms", round(T_waited_fg/100,1) "Waited_FG_sec", W_count_fg "W_count_FG",
        round(T_waited/100,1) "Waited_tot_sec", W_count "W_count_tot"       
from (
  select to_char(min(begin_time),'hh24:mi:ss')||' /'||round(avg(intsize_csec/100),0)||'s' "Time /Delta",
       em.inst_id,en.name,
       sum(em.time_waited_fg) T_waited_fg, sum(em.time_waited) T_waited,sum(wait_count) W_count, sum(wait_count_fg) W_count_fg,
       sum(decode(em.wait_count, 0,0,round(em.time_waited/em.wait_count,2))) T_per_wait,
       sum(decode(em.wait_count_fg, 0,0,round(em.time_waited_fg/em.wait_count_fg,2))) T_per_wait_fg
  from gv$eventmetric em, v$event_name en
  where em.event#=en.event#
      and en.wait_class <>'Idle'
  group by em.inst_id,en.name,em.event_id
  order by T_waited_fg desc
  ) 
where rownum<=20;


set wrap on 

