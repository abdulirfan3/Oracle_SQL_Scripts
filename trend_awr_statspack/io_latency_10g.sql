col event_name format a30
col avg_ms format 99999.99
select
       btime, event_name,
       (time_ms_end-time_ms_beg)/nullif(count_end-count_beg,0) avg_ms,
       (count_end-count_beg) ct
from (
select
       e.event_name,
       to_char(s.BEGIN_INTERVAL_TIME,'DD-MON-YY HH24:MI')  btime,
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
   and s.begin_interval_time > sysdate -2
   and e.wait_class in ( 'User I/O', 'System I/O')
   -- and s.dbid=2
   -- and s.dbid=e.dbid
   -- and s.begin_interval_time > to_date('07-NOV-11 13:00','DD-MON-YY HH24:MI')
   -- and s.begin_interval_time < to_date('07-NOV-11 15:00','DD-MON-YY HH24:MI')
 order by e.event_name, begin_interval_time
)
where (count_end-count_beg) > 0
order by event_name,btime
;