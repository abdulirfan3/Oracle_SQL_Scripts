col event for a40
select
       n.name event,
       m.wait_count  cnt,
       round(((m.time_waited)/6000),2) AAS,
       nvl(round(10*m.time_waited/nullif(m.wait_count,0),3) ,0) avg_ms
     from v$eventmetric m,
          v$event_name n
     where m.event_id=n.event_id
       and m.wait_count > 0
       and wait_class_id != 2723168908
union all
select
         'CPU'  event,
          null cmt,
          round((value/100),2) AAS,
          null avg_ms
     from     v$sysmetric
     where    metric_name in ( 'CPU Usage Per Sec')
       and group_id=2   /* group id for 60 second deltas , group_id 3 is for 15 second deltas */
order by 3 desc;