select  to_char(begin_time,'DD-MON-YY HH24:MI'),
 average, maxval from dba_hist_sysmetric_summary where
metric_name='Average Synchronous Single-Block Read Latency'
order by begin_time;