Prompt
prompt +---------------------------------------+
prompt |   Hourly AVG_MS wait for a event      |
prompt | sample day/hour can be used to grapth |
prompt |   Only last 200 rows are displayed    |
Prompt +---------------------------------------+
prompt
col sample_day format a15
col sample_hour format a15
select * from(
select
       btime,
	  sample_day, sample_hour,
       round((time_ms_end-time_ms_beg)/nullif(count_end-count_beg,0),3) avg_ms
from (
select
       to_char(s.BEGIN_INTERVAL_TIME,'DD-MON-YY HH24:MI')  btime,
	   to_char(s.BEGIN_INTERVAL_TIME, 'YYYYMMDD') sample_day, to_char(s.BEGIN_INTERVAL_TIME,'HH24')sample_hour,
       total_waits count_end,
       time_waited_micro/1000 time_ms_end,
       Lag (e.time_waited_micro/1000)
              OVER( PARTITION BY e.event_name ORDER BY s.snap_id) time_ms_beg,
       Lag (e.total_waits)
              OVER( PARTITION BY e.event_name ORDER BY s.snap_id) count_beg
from
       DBA_HIST_SYSTEM_EVENT e,
       DBA_HIST_SNAPSHOT s
where
         s.snap_id=e.snap_id
   and e.event_name like '&event_name'
order by begin_interval_time
)
order by to_date(btime,'DD-MON-YY HH24:MI') desc)
where rownum < 201;


/*
similar sql but with input of date

alter session set nls_date_format='dd-mon-yy';
set lines 150 pages 100 echo off feedback off
col date_time heading 'Date time|mm/dd/yy_hh_mi_hh_mi' for a30
col event_name for a26
col waits for 99,999,999,999 heading 'Waits'
col time for 99,999 heading 'Total Wait|Time(sec)'
col avg_wait_ms for 99,999 heading 'Avg Wait|(ms)'
prompt "Enter the date in DD-Mon-YY Format:"
WITH system_event AS
 (select sn.begin_interval_time begin_interval_time,
         sn.end_interval_time end_interval_time,
         se.event_name event_name,
         se.total_waits e_total_waits,
         lag(se.total_waits, 1) over(order by se.snap_id) b_total_waits,
         se.total_timeouts e_total_timeouts,
         lag(se.total_timeouts, 1) over(order by se.snap_id) b_total_timeouts,
         se.time_waited_micro e_time_waited_micro,
         lag(se.time_waited_micro, 1) over(order by se.snap_id) b_time_waited_micro
    from dba_hist_system_event se, dba_hist_snapshot sn
   where trunc(sn.begin_interval_time) = '&Date'
     and se.snap_id = sn.snap_id
     and se.dbid = sn.dbid
     and se.instance_number = sn.instance_number
     and se.dbid = (select dbid from v$database)
     and se.instance_number = (select instance_number from v$instance)
     and se.event_name = '&event_name') select to_char
 (se1.BEGIN_INTERVAL_TIME, 'mm/dd/yy_hh24_mi') || to_char
 (se1.END_INTERVAL_TIME, '_hh24_mi') date_time,
se1.event_name,
se1.e_total_waits - nvl(se1.b_total_waits,
0) waits,
(se1.e_time_waited_micro - nvl(se1.b_time_waited_micro,
0)) / 1000000 time,
((se1.e_time_waited_micro - nvl(se1.b_time_waited_micro,
0)) / 1000) / (se1.e_total_waits - nvl(se1.b_total_waits,
0)) avg_wait_ms from system_event se1 where(se1.e_total_waits - nvl(se1.b_total_waits,
0)) > 0 and nvl(se1.b_total_waits,
0) > 0
/
*/